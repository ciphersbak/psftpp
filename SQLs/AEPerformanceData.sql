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

--Additional Queries
SELECT A.* FROM PSAESQLTIMINGS A ORDER BY 1 DESC;
SELECT COUNT(*) OVER (PARTITION BY PROCESS_INSTANCE ORDER BY PROCESS_INSTANCE DESC) "Count", A.* FROM PSAESQLTIMINGS A ORDER BY 1 DESC;
SELECT COUNT(*) OVER () "Count", A.* FROM PSAESQLTIMINGS A ORDER BY PROCESS_INSTANCE DESC;
SELECT COUNT(*) OVER () "Total Rows", 
--       SUM(ROW_NUMBER() OVER (PARTITION BY PROCESS_INSTANCE ORDER BY PROCESS_INSTANCE DESC)) "Count", 
       (ROW_NUMBER() OVER (PARTITION BY PROCESS_INSTANCE ORDER BY PROCESS_INSTANCE DESC)) "Row#", A.* 
FROM PSAESQLTIMINGS A ORDER BY PROCESS_INSTANCE DESC;

--V1
SELECT COUNT(*) OVER () "Total Rows", 
--       SUM(ROW_NUMBER() OVER (PARTITION BY PROCESS_INSTANCE ORDER BY PROCESS_INSTANCE DESC)) "Count", 
       (ROW_NUMBER() OVER (PARTITION BY A.PROCESS_INSTANCE ORDER BY A.PROCESS_INSTANCE DESC, A.STARTDATETIME)) "Row#", A.* 
FROM PSAESQLTIMINGS A 
ORDER BY A.PROCESS_INSTANCE DESC, A.STARTDATETIME;

--V2
--COUNT rows without GROUP BY
SELECT COUNT(*) OVER () "Total Rows", A.PROCESS_INSTANCE, A.AE_APPLID, A.AE_SECTION, A.AE_STEP, A.STARTDATETIME,
       COUNT(*) OVER (PARTITION BY A.PROCESS_INSTANCE ORDER BY A.STARTDATETIME RANGE NUMTODSINTERVAL(extract(second from (A.ENDDATETIME - A.STARTDATETIME)), 'second') PRECEDING) AS t_count       
FROM PSAESQLTIMINGS A
ORDER BY A.PROCESS_INSTANCE DESC, A.STARTDATETIME;

SELECT X.* FROM (
SELECT COUNT(*) OVER () "Total_Rows", 
       (ROW_NUMBER() OVER (PARTITION BY PROCESS_INSTANCE ORDER BY PROCESS_INSTANCE DESC, STARTDATETIME)) "Row#", A.* 
FROM PSAESQLTIMINGS A) X
ORDER BY 3 DESC, STARTDATETIME;

--Testing Queries
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID LIKE 'PC_%' AND FLOW# LIKE '#Jump%' ORDER BY AE_APPLID;
SELECT * FROM PS_PP_AE_FLOW WHERE FLOW# LIKE '#Jump%' AND AE_DO_APPL_ID = 'PC_EDIT' ORDER BY AE_APPLID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_APPLID = 'PC_EDIT' AND FLOW# LIKE '#Jump%';
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'PC_EDIT' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'FS_CEDT_EPC' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'FS_CEDT_PRCS' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'FS_CEDT_GTT' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'FS_CEDT_TAO' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'FS_CEDT_PROC' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID = 'GL_JPROC' AND AE_APPLID <> AE_DO_APPL_ID;
SELECT * FROM PS_PP_AE_FLOW WHERE AE_DO_APPL_ID <> AE_APPLID AND FLOW# LIKE '#Jump%' AND 1 = 1;
SELECT * FROM PS_PP_AE_FLOW WHERE FLOW# LIKE '#Jump%' AND AE_APPLID <> AE_DO_APPL_ID;

--CTE V1
WITH AEDETAILS (FLOW#, AE_APPLID, AE_SECTION, MARKET, EFF_STATUS, AE_STEP, AE_ACTIVE_STATUS, AE_DO_APPL_ID, AE_DO_SECTION) 
AS (SELECT AEP.FLOW#, AEP.AE_APPLID, AEP.AE_SECTION, AEP.MARKET, AEP.EFF_STATUS, AEP.AE_STEP, AEP.AE_ACTIVE_STATUS, AEP.AE_DO_APPL_ID, AEP.AE_DO_SECTION
--           AEP.FLOW#, AEP.AE_APPLID, AEP.AE_SECTION, AEP.MARKET, "Section EFFDT", AEP.EFF_STATUS, "Section DESCR", "AE Step SEQ", AEP.AE_STEP, "Step DESCR", "Commit After", "On Error",
--           AEP.AE_ACTIVE_STATUS, "Step EFFDT", "Dynamic DO", AEP.AE_DO_APPL_ID, AEP.AE_DO_SECTION, "AE Statement Type", "ReUse Statement", "Action DESCR"
    FROM PS_PP_AE_FLOW AEP
    WHERE 1 = 1
    UNION ALL
    SELECT UNP.FLOW#, UNP.AE_APPLID, UNP.AE_SECTION, UNP.MARKET, UNP.EFF_STATUS, UNP.AE_STEP, UNP.AE_ACTIVE_STATUS, UNP.AE_DO_APPL_ID, UNP.AE_DO_SECTION
    FROM AEDETAILS AEP, PS_PP_AE_FLOW UNP
    WHERE AEP.AE_APPLID = UNP.AE_DO_APPL_ID AND UNP.AE_DO_APPL_ID = ' ')
SELECT * FROM AEDETAILS
WHERE AE_DO_APPL_ID = 'PC_EDIT'
  AND AE_DO_APPL_ID <> AE_APPLID
  AND FLOW# LIKE '#Jump%'
  AND 1 = 1;

set feedback on
select * from table(dbms_xplan.display_cursor);

--CTE V2
WITH AEDETAILS (FLOW#, AE_APPLID, AE_SECTION, MARKET, EFF_STATUS, AE_STEP, AE_ACTIVE_STATUS, AE_DO_APPL_ID, AE_DO_SECTION) 
AS (SELECT AE.FLOW#, AE.AE_APPLID, AE.AE_SECTION, AE.MARKET, AE.EFF_STATUS, AE.AE_STEP, AE.AE_ACTIVE_STATUS, AE.AE_DO_APPL_ID, AE.AE_DO_SECTION
    FROM PS_PP_AE_FLOW AE
    WHERE 1 = 1
    UNION ALL
    SELECT AE_1.FLOW#, AE_1.AE_APPLID, AE_1.AE_SECTION, AE_1.MARKET, AE_1.EFF_STATUS, AE_1.AE_STEP, AE_1.AE_ACTIVE_STATUS, AE_1.AE_DO_APPL_ID, AE_1.AE_DO_SECTION
    FROM AEDETAILS AE, PS_PP_AE_FLOW AE_1
    WHERE ((AE.AE_DO_APPL_ID = AE_1.AE_APPLID AND AE.AE_DO_APPL_ID = ' ') 
        OR (AE.AE_APPLID = AE_1.AE_DO_APPL_ID AND AE.AE_APPLID = ' ')))
SELECT A.* FROM AEDETAILS A
WHERE AE_DO_APPL_ID <> AE_APPLID
--  AND (AE_DO_APPL_ID = 'PC_EDIT' OR AE_APPLID = 'PC_EDIT')
  AND FLOW# LIKE '#Jump%'
  AND 1 = 1;
