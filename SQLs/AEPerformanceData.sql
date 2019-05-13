--My Local Build
SELECT * FROM PS_PP_AE_LOG_TBL ORDER BY PROCESS_INSTANCE DESC;

SELECT * FROM PS_PP_PROJ_RES;
--TRUNCATE TABLE PS_PP_PROJ_RES REUSE STORAGE;
SELECT BUSINESS_UNIT, COUNT(*) FROM PS_PROJ_RESOURCE GROUP BY BUSINESS_UNIT;
--WHERE BUSINESS_UNIT = 'US001';

WITH T1 AS
(
SELECT PROCESS_INSTANCE, OPRID, RUNCNTLID, AE_APPLID, AE_SECTION, AE_STEP, DESCR, SQLID, NUMROWS, 
       TO_DATE(TO_CHAR(STARTDATETIME,'yyyymmddhh24.mi.ss'),'yyyymmddhh24.mi.ss') real_start, 
       TO_DATE(TO_CHAR(ENDDATETIME,'yyyymmddhh24.mi.ss'),'yyyymmddhh24.mi.ss') real_end,
       TO_TIMESTAMP(TO_CHAR(STARTDATETIME,'yyyymmddhh24.mi.ssff3'),'yyyymmddhh24.mi.ssff3') new_start, 
       TO_TIMESTAMP(TO_CHAR(ENDDATETIME,'yyyymmddhh24.mi.ssff3'),'yyyymmddhh24.mi.ssff3') new_end
FROM PS_PP_AE_LOG_TBL
)
SELECT PROCESS_INSTANCE, OPRID, RUNCNTLID, AE_APPLID "App Engine", AE_SECTION "Section", AE_STEP "Step", DESCR, SQLID, NUMROWS "Rows(s) Affected", --new_start, new_end,
       CASE 
           WHEN trunc(24*mod(real_end - real_start,1)) < 0
           THEN 86400 + trunc(mod(real_end - real_start,1)*24*60*60,1) --assumption is that its one day
           ELSE trunc(mod(real_end - real_start,1)*24*60*60,1)
       END AS TOTAL_SECONDS, extract(second from new_end - new_start) * 1000 "MILLISECONDS",
       trunc(real_end - real_start) days, trunc(24*mod(real_end - real_start,1)) as hrs, trunc(mod(mod(real_end - real_start,1)*24,1)*60 ) as mins, 
       trunc(mod(mod(mod(real_end - real_start,1)*24,1)*60, 1)*60) as seconds
FROM T1 
ORDER BY PROCESS_INSTANCE DESC;

--8.58_134W Build
--Version 1
WITH T1 AS
(
SELECT AEP.PROCESS_INSTANCE, AEP.OPRID, AEP.RUN_CNTL_ID, AEP.AE_APPLID, AEP.AE_SECTION, AEP.AE_STEP, AEP.PTAE_SQL_TYPE, AEP.PTAE_ITERATION, AEP.SQLID, AEP.PTAE_SQL_ROWS, 
       TO_DATE(TO_CHAR(AEP.STARTDATETIME,'yyyymmddhh24.mi.ss'),'yyyymmddhh24.mi.ss') real_start, 
       TO_DATE(TO_CHAR(AEP.ENDDATETIME,'yyyymmddhh24.mi.ss'),'yyyymmddhh24.mi.ss') real_end,
      --Improve precision
       TO_TIMESTAMP(TO_CHAR(AEP.STARTDATETIME,'yyyymmddhh24.mi.ssff9'),'yyyymmddhh24.mi.ssff9') new_start, 
       TO_TIMESTAMP(TO_CHAR(AEP.ENDDATETIME,'yyyymmddhh24.mi.ssff9'),'yyyymmddhh24.mi.ssff9') new_end
FROM PSAESQLTIMINGS AEP
)
SELECT PROCESS_INSTANCE, OPRID, RUN_CNTL_ID, AE_APPLID "App Engine", AE_SECTION "Section", AE_STEP "Step", PTAE_SQL_TYPE "DML Type", PTAE_ITERATION "Exec Count", 
       SQLID "Oracle SQLID", PTAE_SQL_ROWS "Rows(s) Affected",
--       CASE 
--           WHEN trunc(24*mod(real_end - real_start,1)) < 0
--           THEN 86400 + trunc(mod(real_end - real_start,1)*24*60*60,1) --assumption is that its one day
--           ELSE trunc(mod(real_end - real_start,1)*24*60*60,1)
--       END AS TOTAL_SECONDS, extract(second from new_end - new_start) * 1000 "MILLISECONDS",
--       CASE 
--           WHEN trunc(24*mod(new_end - new_start,1)) < 0
--           THEN 86400 + trunc(mod(new_end - new_start,1)*24*60*60,1) --assumption is that its one day
--           ELSE trunc(mod(new_end - new_start,1)*24*60*60,1)
--       END AS PRECISION_SECONDS,
       extract(day from (new_end - new_start))*24*60*60+extract(hour from (new_end - new_start))*60*60+extract(minute from (new_end - new_start))*60
                                                       +extract(second from (new_end - new_start)) "Precision Seconds",
       numtodsinterval(extract(day from (new_end - new_start))*24*60*60+extract(hour from (new_end - new_start))*60*60+extract(minute from (new_end - new_start))*60
                                                       +extract(second from (new_end - new_start)), 'second') "Precision Sec",       
       new_start "Actual START", new_end "Actual END", 
       trunc(real_end - real_start) days, trunc(24*mod(real_end - real_start,1)) as hrs, trunc(mod(mod(real_end - real_start,1)*24,1)*60 ) as mins, 
       trunc(mod(mod(mod(real_end - real_start,1)*24,1)*60, 1)*60) as seconds
FROM T1 
ORDER BY PROCESS_INSTANCE DESC, new_start;
