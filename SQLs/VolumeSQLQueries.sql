--E92PCVOL SQL Queries

---------------------
--TAB 1
---------------------
column "Tablespace" format a13
column "Used MB"    format 99,999,999
column "Free MB"    format 99,999,999
column "Total MB"   format 99,999,999
select
   fs.tablespace_name                          "Tablespace",
   (df.totalspace - fs.freespace)              "Used MB",
   fs.freespace                                "Free MB",
   df.totalspace                               "Total MB",
   round(100 * (fs.freespace / df.totalspace)) "Pct. Free"
from
   (select tablespace_name, round(sum(bytes) / 1048576) TotalSpace
   from dba_data_files
   group by tablespace_name) df,
   (select tablespace_name, round(sum(bytes) / 1048576) FreeSpace
   from dba_free_space
   group by tablespace_name) fs
where df.tablespace_name = fs.tablespace_name
  --and round(100 * (fs.freespace / df.totalspace)) <> 100
  --and (fs.tablespace_name LIKE 'PC%' OR fs.tablespace_name LIKE 'PS%')
ORDER BY round(100 * (fs.freespace / df.totalspace));


--Size of All Table Space

--1. Used Space
SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024/1024, '99,999,990.99') AS "USED SPACE(IN GB)" FROM USER_SEGMENTS GROUP BY TABLESPACE_NAME;
--2. Free Space
SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024/1024, '99,999,990.99') AS "FREE SPACE(IN GB)" FROM   USER_FREE_SPACE GROUP BY TABLESPACE_NAME;

--3. Both Free & Used
SELECT USED.TABLESPACE_NAME, USED.USED_BYTES AS "USED SPACE(IN GB)",  FREE.FREE_BYTES AS "FREE SPACE(IN GB)"
FROM
(SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024/1024, '99,999,990.99') AS USED_BYTES FROM USER_SEGMENTS GROUP BY TABLESPACE_NAME) USED
INNER JOIN
(SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024/1024, '99,999,990.99') AS FREE_BYTES FROM  USER_FREE_SPACE GROUP BY TABLESPACE_NAME) FREE
ON (USED.TABLESPACE_NAME = FREE.TABLESPACE_NAME);

---------------------
--TAB 2
---------------------

COLUMN sid FORMAT 999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.sid, s.serial#, s.machine, --sl.opname, sl.sql_id, sl.sql_plan_operation, sl.sql_plan_options,
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct
FROM   v$session s, v$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
--AND    (ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) <> '0:0' OR ROUND(sl.sofar/sl.totalwork*100, 2) <> '100.00')
/

select ses.sid, ses.serial#, ses.username, ses.machine, ses.program, ses.status, ses.last_call_et, sql.hash_value, sql.sql_text
from v$session ses, v$sql sql
where ses.sql_hash_value = sql.hash_value
and ses.type = 'USER'
AND ses.status = 'ACTIVE';

SELECT * FROM v$session_longops WHERE opname LIKE '%Gather%' AND time_remaining != 0
ORDER BY SID;

select table_name, owner, to_char(last_analyzed, 'dd-mon-yyyy hh24:mi:ss'), A.* from dba_tables A where table_name = 'PS_PR_RES_PA_TA0';
select num_rows, sample_size, blocks, blocks*8192/1048576 Size_MB from user_tables where table_name = 'PS_PROJ_RESOURCE';

select column_name, num_distinct, num_nulls, histogram, num_buckets, A.* from user_tab_col_statistics A where table_name = 'PS_PROJ_RESOURCE';

--To reclaim space, use the shrink command to re-organize data
ALTER TABLE EMDBO.PS_PROJ_RESOURCE enable row movement;
--Re-arrange rows 
ALTER TABLE EMDBO.PS_PROJ_RESOURCE shrink space compact;
--Reset the HWM
ALTER TABLE EMDBO.PS_PROJ_RESOURCE shrink space;

BEGIN
  --DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => USER,TABNAME => 'PS_PROJ_RESOURCE',FORCE=>TRUE,CASCADE => TRUE,DEGREE => 4);
  --DBMS_STATS.GATHER_TABLE_STATS ('emdbo', 'PS_PROJ_RESOURCE', ESTIMATE_PERCENT=>1, METHOD_OPT=> 'FOR ALL INDEXED COLUMNS SIZE 1',CASCADE=>TRUE);
  DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
end;

EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE');
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>USER,TABNAME=>'PS_PROJ_RESOURCE');
--EXEC DBMS_STATS.DELETE_TABLE_STATS(OWNNAME=>user,TABNAME=>'PS_GPFR_RSLT_TMP_P');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE', ESTIMATE_PERCENT=>1, METHOD_OPT=> 'FOR ALL INDEXED COLUMNS SIZE 1',CASCADE=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);


SELECT :1, RTRIM(XMLAGG(XMLELEMENT(E,column_name, ', ').EXTRACT('//text()') ORDER BY column_id).GETCLOBVAL(),',') column_list
--LISTAGG(UPPER(column_name), ', ') WITHIN GROUP (ORDER BY column_id) column_list
FROM user_tab_columns
WHERE table_name = :1
GROUP BY :1
ORDER BY :1;


SELECT ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, RESOURCE_QUANTITY, A.RESOURCE_AMOUNT, A.* 
FROM PS_PROJ_RESOURCE A WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'MYVOLPROJ' ORDER BY DTTM_STAMP DESC;

SELECT ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, RESOURCE_QUANTITY, A.RESOURCE_AMOUNT, A.* 
FROM PS_PROJ_RESOURCE A WHERE BUSINESS_UNIT = 'US001' ORDER BY DTTM_STAMP DESC;

SELECT ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, RESOURCE_QUANTITY, A.RESOURCE_AMOUNT, A.* 
FROM PS_PROJ_RESOURCE A WHERE BUSINESS_UNIT = 'US001' AND PROJECT_ID LIKE '%168' AND ANALYSIS_TYPE = 'ACT' ORDER BY DTTM_STAMP DESC;

SELECT PC_DISTRIB_STATUS, A.* FROM PS_PO_LINE_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND PO_ID LIKE 'A%';

SELECT BUSINESS_UNIT, ANALYSIS_TYPE, COUNT(1) FROM PS_PROJ_RESOURCE GROUP BY BUSINESS_UNIT, ANALYSIS_TYPE ORDER BY 3 DESC;

SELECT * FROM PS_PO_HDR WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000359';

SELECT * FROM PSSQLTEXTDEFN WHERE SQLID LIKE 'PC_POADJUST%' AND UPPER(SQLTEXT) LIKE '%UPDATESTATS%' ORDER BY 1;
SELECT * FROM PSSQLTEXTDEFN WHERE SQLID LIKE 'PC_POADJUST%' AND UPPER(SQLTEXT) LIKE '%TRUNCATE%' ORDER BY 1;


---------------------
--TAB 3
---------------------

--Current Running SQLs
--------------------
set pages 50000 lines 32767
col HOST_NAME for a20
col EVENT for a40
col MACHINE for a30
col SQL_TEXT for a50
col USERNAME for a15

select sid,serial#,a.sql_id,a.SQL_TEXT,S.USERNAME,i.host_name,machine,S.event,S.seconds_in_wait sec_wait,
to_char(logon_time,'DD-MON-RR HH24:MI') login
from gv$session S,gV$SQLAREA A,gv$instance i
where S.username is not null
--  and S.status='ACTIVE'
AND S.sql_address=A.address
and s.inst_id=a.inst_id and i.inst_id = a.inst_id
and sql_text not like 'select S.USERNAME,S.seconds_in_wait%'
/

--Current Running SQLs
--------------------
set pages 50000 lines 32767
col program format a20
col sql_text format a50

select b.sid,b.status,b.last_call_et,TO_CHAR(last_call_et/60, '999.99') Minutes,b.program,c.sql_id,c.sql_text
from v$session b,v$sqlarea c
where b.sql_id=c.sql_id
/


set pages 50000 lines 32767
col "Last SQL" for a100
SELECT t.inst_id,s.username, s.sid, s.serial#,t.sql_id,t.sql_text "Last SQL"
FROM gv$session s, gv$sqlarea t
WHERE s.sql_address =t.address AND
s.sql_hash_value =t.hash_value
/

select sid, serial#, opname, target, round(sofar/totalwork*100,2) as percent_done, start_time, last_update_time, time_remaining, elapsed_seconds, sofar, totalwork, sql_id, 
       sql_plan_operation, sql_plan_options
from v$session_longops --WHERE SOFAR < TOTALWORK
ORDER BY LAST_UPDATE_TIME DESC
/

--Take the SQL_ID returned by the above query and identify the long running SQL
SELECT CHILD_NUMBER, CPU_TIME, ELAPSED_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, PLSQL_EXEC_TIME, ROWS_PROCESSED, ACTION,  A.*
FROM V$SQL A WHERE  SQL_ID = '8bkpvd7rrctjn' --Put your SQL_ID here
/

---------------------
--TAB 4
---------------------
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_HDR', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_LINE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_LINE_SHIP', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_LN_DISTRIB', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PO_HDR', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PO_LINE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PO_LINE_SHIP', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PO_LINE_DISTRIB', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_VOUCHER', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_VCHR_REG_LC', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_VOUCHER_LINE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_DISTRIB_LINE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_VCHR_ACCTG_LINE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PYMNT_VCHR_XREF', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);


SELECT * FROM PSRECTBLSPC WHERE 
RECNAME IN ('REQ_HDR', 'REQ_LINE', 'REQ_LINE_SHIP', 'REQ_LN_DISTRIB', 'PO_HDR', 'PO_LINE_SHIP', 'PO_LINE_DISTRIB', 'VOUCHER', 'VCHR_REG_LC', 'VOUCHER_LINE', 'DISTRIB_LINE', 'VCHR_ACCTG_LINE', 
'PYMNT_VCHR_XREF', 'PROJ_RESOURCE');

SELECT * FROM PSRECTBLSPC WHERE RECNAME LIKE 'PC_RES%TA%';

SELECT DISTINCT DDLSPACENAME FROM PSRECTBLSPC WHERE DDLSPACENAME LIKE 'PS%';

SELECT * FROM PSRECTBLSPC WHERE DDLSPACENAME = 'PSGTT01';



SELECT * FROM PS_INSTALLATION_AM;
SELECT * FROM PS_AM_INSTALL_AET;
SELECT * FROM PSRECFIELDDB WHERE RECNAME = 'INSTALLATION_AM' ORDER BY FIELDNUM;
SELECT * FROM PSRECFIELDDB WHERE RECNAME = 'AM_INSTALL_AET' ORDER BY FIELDNUM;


SELECT * FROM PSSQLTEXTDEFN WHERE SQLID = 'AM_GET_INSTALLATION_OPTIONS';


SELECT DISTINCT PROCESS_INSTANCE, OPRID, RUN_CNTL_ID, AE_APPLID, RUN_DTTM 
FROM PS_AETEMPTBLMGR 
WHERE PROCESS_INSTANCE NOT IN (SELECT PRCSINSTANCE FROM PSPRCSRQST) 
    AND PROCESS_INSTANCE NOT IN (SELECT PROCESS_INSTANCE FROM PS_AERUNCONTROL)
UNION 
SELECT DISTINCT PROCESS_INSTANCE, OPRID, RUN_CNTL_ID, AE_APPLID, RUN_DTTM 
FROM PS_AERUNCONTROL 
WHERE PROCESS_INSTANCE NOT IN (SELECT PRCSINSTANCE FROM PSPRCSRQST) 
ORDER BY PROCESS_INSTANCE DESC;


SELECT PC_DISTRIB_STATUS , DST_ACCT_TYPE, BUDGET_HDR_STATUS, BUDGET_LINE_STATUS, A.* FROM PS_VCHR_ACCTG_LINE A 
WHERE VOUCHER_ID LIKE 'S%' AND PROJECT_ID = 'DELCRV' AND BUSINESS_UNIT_PC = 'US004';

SELECT PC_DISTRIB_STATUS , A.* FROM PS_REQ_LN_DISTRIB A 
WHERE REQ_ID LIKE 'S%' AND PROJECT_ID = 'DELCRV' AND BUSINESS_UNIT_PC = 'US004';

---------------------
--TAB 5
---------------------

SELECT TRANS_DT, ACCOUNTING_DT, ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, A.* FROM PS_PROJ_RESOURCE A WHERE BUSINESS_UNIT = 'US005' ORDER BY DTTM_STAMP DESC;
SELECT * FROM PS_PROJ_RESOURCE WHERE ANALYSIS_TYPE = 'CCA';

--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'W1234567', 'W', 100000); -- Used
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'V1234567', 'V', 100000); -- Used
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'U1234567', 'U', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'T1234567', 'T', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'R1234567', 'R', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'Q1234567', 'Q', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'P1234567', 'P', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'O1234567', 'O', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'N1234567', 'N', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'M1234567', 'M', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'L1234567', 'L', 100000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'K1234567', 'K', 100000);

SELECT * FROM PS_REQ_HDR WHERE BUSINESS_UNIT IN ('US001', 'US004', 'US005')
AND (REQ_ID LIKE 'W%' OR REQ_ID LIKE 'V%' OR REQ_ID LIKE 'U%' OR REQ_ID LIKE 'T%' OR REQ_ID LIKE 'R%' OR REQ_ID LIKE 'Q%' OR REQ_ID LIKE 'P%' OR REQ_ID LIKE 'O%' OR REQ_ID LIKE 'N%' OR 
REQ_ID LIKE 'M%' OR REQ_ID LIKE 'L%' OR REQ_ID LIKE 'K%');

column "Tablespace" format a13
column "Used MB"    format 99,999,999
column "Free MB"    format 99,999,999
column "Total MB"   format 99,999,999
select
   fs.tablespace_name                          "Tablespace",
   (df.totalspace - fs.freespace)              "Used MB",
   fs.freespace                                "Free MB",
   df.totalspace                               "Total MB",
   round(100 * (fs.freespace / df.totalspace)) "Pct. Free"
from
   (select tablespace_name, round(sum(bytes) / 1048576) TotalSpace
   from dba_data_files
   group by tablespace_name) df,
   (select tablespace_name, round(sum(bytes) / 1048576) FreeSpace
   from dba_free_space
   group by tablespace_name) fs
where df.tablespace_name = fs.tablespace_name
  --and round(100 * (fs.freespace / df.totalspace)) <> 100
  --and (fs.tablespace_name LIKE 'PC%' OR fs.tablespace_name LIKE 'PS%')
--ORDER BY round(100 * (fs.freespace / df.totalspace));
ORDER BY df.totalspace DESC;


SELECT TRANS_DT, ACCOUNTING_DT, ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, A.* FROM PS_PROJ_RESOURCE A WHERE BUSINESS_UNIT = 'US005' ORDER BY DTTM_STAMP DESC;
SELECT COUNT(ANALYSIS_TYPE) FROM PS_PROJ_RESOURCE WHERE BUSINESS_UNIT = 'US005' AND ANALYSIS_TYPE = 'CCA';
SELECT * FROM PS_PO_HDR WHERE BUSINESS_UNIT = 'US001' AND PO_ID LIKE 'V%';

--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'PP123456', 'W', 10000);
--EXECUTE INSERT_BULK_PO_VOUCHERS_PP('US001', 'AB123456', 'V', 1000000);

---------------------
--TAB 6
---------------------

SELECT CHILD_NUMBER, CPU_TIME, ELAPSED_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, PLSQL_EXEC_TIME, ROWS_PROCESSED, ACTION,  A.*
FROM V$SQL A 
WHERE SQL_ID IN ('9xq3w1yy7btdp', 'cnnz730m97342', '0kn5b88d27zw5', 'afh91g1s7p7pg', '0wz6vaks654qc');

BEGIN DBMS_STATS.GATHER_TABLE_STATS (ownname=> 'EMDBO', tabname=>'PS_PROJ_RES_TMP', estimate_percent=>1, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE); END;
--EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_HDR', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
BEGIN DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_REQ_HDR', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE); END;

select /*+  no_parallel_index(t, "PSEPROJ_RES_TMP")  dbms_stats cursor_sharing_exact use_weak_name_resl dynamic_sampling(0) no_monitoring xmlindex_sel_idx_tbl no_substrb_pad  
            no_expand index_ffs(t,"PSEPROJ_RES_TMP") */ 
            count(*) as nrw, count(distinct sys_op_lbid(56795,'L',t.rowid)) as nlb, 
            count(distinct hextoraw(sys_op_descend("PROCESS_INSTANCE")||sys_op_descend("BUSINESS_UNIT")||sys_op_descend("PROJECT_ID")||sys_op_descend("ACTIVITY_ID")
            ||sys_op_descend("ANALYSIS_TYPE")||sys_op_descend("RESOURCE_TYPE")||sys_op_descend("RESOURCE_CATEGORY")||sys_op_descend("RESOURCE_SUB_CAT")||sys_op_descend("JOBCODE")
            ||sys_op_descend("EMPLID")||sys_op_descend("BI_DISTRIB_STATUS")||sys_op_descend("GL_DISTRIB_STATUS")||sys_op_descend("UNIT_OF_MEASURE")||sys_op_descend("CURRENCY_CD"))) as ndk, 
            sys_op_countchg(substrb(t.rowid,1,15),1) as clf 
from "EMDBO"."PS_PROJ_RES_TMP" t 
where "PROCESS_INSTANCE" is not null 
   or "BUSINESS_UNIT" is not null 
   or "PROJECT_ID" is not null 
   or "ACTIVITY_ID" is not null 
   or "ANALYSIS_TYPE" is not null 
   or "RESOURCE_TYPE" is not null 
   or "RESOURCE_CATEGORY" is not null 
   or "RESOURCE_SUB_CAT" is not null 
   or "JOBCODE" is not null 
   or "EMPLID" is not null 
   or "BI_DISTRIB_STATUS" is not null 
   or "GL_DISTRIB_STATUS" is not null 
   or "UNIT_OF_MEASURE" is not null 
   or "CURRENCY_CD" is not null
/   
select /*+  no_parallel(t) no_parallel_index(t) dbms_stats cursor_sharing_exact use_weak_name_resl dynamic_sampling(0) no_monitoring xmlindex_sel_idx_tbl no_substrb_pad  */ 
       count(*), count("SYS_STS8WLABXHLT8P1O2DEFGTXRTG"), sum(sys_op_opnsize("SYS_STS8WLABXHLT8P1O2DEFGTXRTG")), count("SYS_STSW839X4G82DW_VLZ9D0CA5YX"), 
       sum(sys_op_opnsize("SYS_STSW839X4G82DW_VLZ9D0CA5YX")), count("SYS_STSZ3MK3F18XRNLR2TT439SCMT"), sum(sys_op_opnsize("SYS_STSZ3MK3F18XRNLR2TT439SCMT")), 
       count("SYS_STSF1ILYYY4#SWWV3X_V04JT89"), sum(sys_op_opnsize("SYS_STSF1ILYYY4#SWWV3X_V04JT89")), sum(sys_op_opnsize("EX_DOC_ID")), sum(sys_op_opnsize("EX_DOC_TYPE")), 
       sum(sys_op_opnsize("RESOURCE_QUANTITY")), sum(sys_op_opnsize("RESOURCE_AMOUNT")), sum(sys_op_opnsize("BUDGET_HDR_STATUS")), sum(sys_op_opnsize("KK_AMOUNT_TYPE")), 
       sum(sys_op_opnsize("KK_TRAN_OVER_FLAG")), sum(sys_op_opnsize("KK_TRAN_OVER_OPRID")), count("KK_TRAN_OVER_DTTM"), sum(sys_op_opnsize("BUDGET_OVER_ALLOW")), 
       sum(sys_op_opnsize("BUDGET_LINE_STATUS")), count("BUDGET_DT"), sum(sys_op_opnsize("LEDGER")), sum(sys_op_opnsize("BD_DISTRIB_STATUS")), sum(sys_op_opnsize("BUSINESS_UNIT_BD")), 
       sum(sys_op_opnsize("FA_STATUS")), sum(sys_op_opnsize("TIME_SHEET_ID")), sum(sys_op_opnsize("SHEET_ID")), count("DT_TIMESTAMP"), sum(sys_op_opnsize("VCHR_DIST_LINE_NUM")), 
       sum(sys_op_opnsize("PM_REVIEWED")), sum(sys_op_opnsize("PRICED_RATE")), sum(sys_op_opnsize("ACTIVITY_ID_DETAIL")), sum(sys_op_opnsize("CST_DISTRIB_STATUS")), 
       sum(sys_op_opnsize("TXN_LMT_TRANS_ID")), sum(sys_op_opnsize("EVENT_NUM")), sum(sys_op_opnsize("CA_FEE_STATUS")), sum(sys_op_opnsize("BUSINESS_UNIT_WO")), 
       sum(sys_op_opnsize("WO_ID")), sum(sys_op_opnsize("WO_TASK_ID")), sum(sys_op_opnsize("RSRC_TYPE")), sum(sys_op_opnsize("RES_LN_NBR")), sum(sys_op_opnsize("COMPRESS_ID")), 
       sum(sys_op_opnsize("AMOUNT_IN_EXCESS")), sum(sys_op_opnsize("RECLAIMED_FROM_OL")), sum(sys_op_opnsize("FND_DIST_STATUS")), sum(sys_op_opnsize("SEQ_TRANS_ID")), 
       sum(sys_op_opnsize("DIST_TRANS_ID")), sum(sys_op_opnsize("ADJ_LINE_TYPE")), sum(sys_op_opnsize("FEEDER_SUM_ID")), sum(sys_op_opnsize("PRICE_SUM_ID")), 
       sum(sys_op_opnsize("DEPOSIT_BU")), sum(sys_op_opnsize("DEPOSIT_ID")), sum(sys_op_opnsize("PAYMENT_SEQ_NUM")), sum(sys_op_opnsize("PC_TEMPLATE_ID")), sum(sys_op_opnsize("RATE_PLAN")), 
       sum(sys_op_opnsize("LINE_NO")), sum(sys_op_opnsize("SEQ_NUM")), sum(sys_op_opnsize("PROCESSED_ROW")), sum(sys_op_opnsize("RATE_PLAN_TYPE")), sum(sys_op_opnsize("TEMPLATE_TYPE")), 
       sum(sys_op_opnsize("RATE_DEF_TYPE")), sum(sys_op_opnsize("ADJUSTING_ENTRY")), sum(sys_op_opnsize("JOURNAL_LINE")), sum(sys_op_opnsize("FISCAL_YEAR")), 
       sum(sys_op_opnsize("ACCOUNTING_PERIOD")), sum(sys_op_opnsize("ACCOUNT")), sum(sys_op_opnsize("ALTACCT")), sum(sys_op_opnsize("DEPTID")), sum(sys_op_opnsize("OPERATING_UNIT")), 
       sum(sys_op_opnsize("PRODUCT")), sum(sys_op_opnsize("FUND_CODE")), sum(sys_op_opnsize("CLASS_FLD")), sum(sys_op_opnsize("PROGRAM_CODE")), sum(sys_op_opnsize("BUDGET_REF")), 
       sum(sys_op_opnsize("AFFILIATE")), sum(sys_op_opnsize("AFFILIATE_INTRA1")), sum(sys_op_opnsize("AFFILIATE_INTRA2")), sum(sys_op_opnsize("CHARTFIELD1")), 
       sum(sys_op_opnsize("CHARTFIELD2")), sum(sys_op_opnsize("CHARTFIELD3")), sum(sys_op_opnsize("BUS_UNIT_GL_FROM")), count(distinct "CURRENCY_CD"), sum(sys_op_opnsize("CURRENCY_CD")), 
       substrb(dump(min("CURRENCY_CD"),16,0,64),1,240), substrb(dump(max("CURRENCY_CD"),16,0,64),1,240), sum(sys_op_opnsize("STATISTICS_CODE")), sum(sys_op_opnsize("LEDGER_GROUP")), 
       count(distinct "ANALYSIS_TYPE"), sum(sys_op_opnsize("ANALYSIS_TYPE")), substrb(dump(min("ANALYSIS_TYPE"),16,0,64),1,240), substrb(dump(max("ANALYSIS_TYPE"),16,0,64),1,240), 
       count(distinct "RESOURCE_TYPE"), sum(sys_op_opnsize("RESOURCE_TYPE")), substrb(dump(min("RESOURCE_TYPE"),16,0,64),1,240), substrb(dump(max("RESOURCE_TYPE"),16,0,64),1,240), 
       count(distinct "RESOURCE_CATEGORY"), sum(sys_op_opnsize("RESOURCE_CATEGORY")), substrb(dump(min("RESOURCE_CATEGORY"),16,0,64),1,240), 
       substrb(dump(max("RESOURCE_CATEGORY"),16,0,64),1,240), count(distinct "RESOURCE_SUB_CAT"), sum(sys_op_opnsize("RESOURCE_SUB_CAT")), 
       substrb(dump(min("RESOURCE_SUB_CAT"),16,0,64),1,240), substrb(dump(max("RESOURCE_SUB_CAT"),16,0,64),1,240), sum(sys_op_opnsize("RES_USER1")), sum(sys_op_opnsize("RES_USER2")), 
       sum(sys_op_opnsize("RES_USER3")), sum(sys_op_opnsize("RES_USER4")), sum(sys_op_opnsize("RES_USER5")), count("TRANS_DT"), count(distinct "TRANS_DT"), 
       substrb(dump(min("TRANS_DT"),16,0,64),1,240), substrb(dump(max("TRANS_DT"),16,0,64),1,240), count("ACCOUNTING_DT"), count(distinct "ACCOUNTING_DT"), 
       substrb(dump(min("ACCOUNTING_DT"),16,0,64),1,240), substrb(dump(max("ACCOUNTING_DT"),16,0,64),1,240), sum(sys_op_opnsize("OPRID")), count("DTTM_STAMP"), 
       sum(sys_op_opnsize("JRNL_LN_REF")), sum(sys_op_opnsize("OPEN_ITEM_STATUS")), sum(sys_op_opnsize("LINE_DESCR")), sum(sys_op_opnsize("JRNL_LINE_STATUS")), 
       count("JOURNAL_LINE_DATE"), sum(sys_op_opnsize("FOREIGN_CURRENCY")), sum(sys_op_opnsize("RT_TYPE")), sum(sys_op_opnsize("FOREIGN_AMOUNT")), sum(sys_op_opnsize("RATE_MULT")), 
       sum(sys_op_opnsize("RATE_DIV")), count("CUR_EFFDT"), sum(sys_op_opnsize("PC_DISTRIB_STATUS")), count(distinct "GL_DISTRIB_STATUS"), sum(sys_op_opnsize("GL_DISTRIB_STATUS")), 
       substrb(dump(min("GL_DISTRIB_STATUS"),16,0,64),1,240), substrb(dump(max("GL_DISTRIB_STATUS"),16,0,64),1,240), sum(sys_op_opnsize("PROJ_TRANS_TYPE")), 
       sum(sys_op_opnsize("PROJ_TRANS_CODE")), sum(sys_op_opnsize("RESOURCE_STATUS")), sum(sys_op_opnsize("DESCR")), count(distinct "SYSTEM_SOURCE"), sum(sys_op_opnsize("SYSTEM_SOURCE")), 
       substrb(dump(min("SYSTEM_SOURCE"),16,0,64),1,240), substrb(dump(max("SYSTEM_SOURCE"),16,0,64),1,240), count(distinct "UNIT_OF_MEASURE"), sum(sys_op_opnsize("UNIT_OF_MEASURE")), 
       substrb(dump(min("UNIT_OF_MEASURE"),16,0,64),1,240), substrb(dump(max("UNIT_OF_MEASURE"),16,0,64),1,240), count(distinct "EMPLID"), sum(sys_op_opnsize("EMPLID")), 
       substrb(dump(min("EMPLID"),16,0,64),1,240), substrb(dump(max("EMPLID"),16,0,64),1,240), sum(sys_op_opnsize("EMPL_RCD")), sum(sys_op_opnsize("SEQ_NBR")), 
       sum(sys_op_opnsize("TIME_RPTG_CD")), count(distinct "JOBCODE"), sum(sys_op_opnsize("JOBCODE")), substrb(dump(min("JOBCODE"),16,0,64),1,240), 
       substrb(dump(max("JOBCODE"),16,0,64),1,240), sum(sys_op_opnsize("COMPANY")), sum(sys_op_opnsize("BUSINESS_UNIT_AP")), sum(sys_op_opnsize("VENDOR_ID")), 
       sum(sys_op_opnsize("VOUCHER_ID")), sum(sys_op_opnsize("VOUCHER_LINE_NUM")), sum(sys_op_opnsize("APPL_JRNL_ID")), sum(sys_op_opnsize("PYMNT_CNT")), 
       sum(sys_op_opnsize("DST_ACCT_TYPE")), sum(sys_op_opnsize("PO_DISTRIB_STATUS")), sum(sys_op_opnsize("BUSINESS_UNIT_PO")), sum(sys_op_opnsize("REQ_ID")), 
       sum(sys_op_opnsize("REQ_LINE_NBR")), sum(sys_op_opnsize("REQ_SCHED_NBR")), sum(sys_op_opnsize("REQ_DISTRIB_NBR")), sum(sys_op_opnsize("PO_ID")), count("DUE_DATE"), 
       sum(sys_op_opnsize("LINE_NBR")), sum(sys_op_opnsize("SCHED_NBR")), sum(sys_op_opnsize("DISTRIB_LINE_NUM")), sum(sys_op_opnsize("AM_DISTRIB_STATUS")), 
       sum(sys_op_opnsize("BUSINESS_UNIT_AM")), sum(sys_op_opnsize("ASSET_ID")), sum(sys_op_opnsize("PROFILE_ID")), sum(sys_op_opnsize("COST_TYPE")), sum(sys_op_opnsize("BOOK")), 
       sum(sys_op_opnsize("INCENTIVE_ID")), sum(sys_op_opnsize("MSTONE_SEQ")), count(distinct "CONTRACT_NUM"), sum(sys_op_opnsize("CONTRACT_NUM")), 
       substrb(dump(min(substrb("CONTRACT_NUM",1,64)),16,0,64),1,240), substrb(dump(max(substrb("CONTRACT_NUM",1,64)),16,0,64),1,240), count(distinct "CONTRACT_LINE_NUM"), 
       sum(sys_op_opnsize("CONTRACT_LINE_NUM")), substrb(dump(min("CONTRACT_LINE_NUM"),16,0,64),1,240), substrb(dump(max("CONTRACT_LINE_NUM"),16,0,64),1,240), 
       sum(sys_op_opnsize("CONTRACT_PPD_SEQ")), count(distinct "BI_DISTRIB_STATUS"), sum(sys_op_opnsize("BI_DISTRIB_STATUS")), substrb(dump(min("BI_DISTRIB_STATUS"),16,0,64),1,240), 
       substrb(dump(max("BI_DISTRIB_STATUS"),16,0,64),1,240), sum(sys_op_opnsize("BUSINESS_UNIT_BI")), count("BILLING_DATE"), sum(sys_op_opnsize("INVOICE")), 
       sum(sys_op_opnsize("REV_DISTRIB_STATUS")), sum(sys_op_opnsize("BUSINESS_UNIT_AR")), sum(sys_op_opnsize("CUST_ID")), sum(sys_op_opnsize("ITEM")), sum(sys_op_opnsize("ITEM_LINE")), 
       sum(sys_op_opnsize("ITEM_SEQ_NUM")), sum(sys_op_opnsize("DST_SEQ_NUM")), sum(sys_op_opnsize("BUSINESS_UNIT_IN")), sum(sys_op_opnsize("SCHED_LINE_NO")), 
       sum(sys_op_opnsize("DEMAND_LINE_NO")), sum(sys_op_opnsize("INV_ITEM_ID")), count("PAY_END_DT"), sum(sys_op_opnsize("BUSINESS_UNIT_OM")), sum(sys_op_opnsize("ORDER_NO")), 
       sum(sys_op_opnsize("ORDER_INT_LINE_NO")), count(distinct "PROCESS_INSTANCE"), sum(sys_op_opnsize("PROCESS_INSTANCE")), substrb(dump(min("PROCESS_INSTANCE"),16,0,64),1,240), 
       substrb(dump(max("PROCESS_INSTANCE"),16,0,64),1,240), count(distinct "BUSINESS_UNIT"), sum(sys_op_opnsize("BUSINESS_UNIT")), substrb(dump(min("BUSINESS_UNIT"),16,0,64),1,240), 
       substrb(dump(max("BUSINESS_UNIT"),16,0,64),1,240), count(distinct "PROJECT_ID"), sum(sys_op_opnsize("PROJECT_ID")), substrb(dump(min("PROJECT_ID"),16,0,64),1,240), 
       substrb(dump(max("PROJECT_ID"),16,0,64),1,240), count(distinct "ACTIVITY_ID"), sum(sys_op_opnsize("ACTIVITY_ID")), substrb(dump(min("ACTIVITY_ID"),16,0,64),1,240), 
       substrb(dump(max("ACTIVITY_ID"),16,0,64),1,240), count(distinct "RESOURCE_ID"), sum(sys_op_opnsize("RESOURCE_ID")), substrb(dump(min(substrb("RESOURCE_ID",1,64)),16,0,64),1,240), 
       substrb(dump(max(substrb("RESOURCE_ID",1,64)),16,0,64),1,240), count(distinct "RESOURCE_ID_FROM"), sum(sys_op_opnsize("RESOURCE_ID_FROM")), 
       substrb(dump(min(substrb("RESOURCE_ID_FROM",1,64)),16,0,64),1,240), substrb(dump(max(substrb("RESOURCE_ID_FROM",1,64)),16,0,64),1,240), sum(sys_op_opnsize("BUSINESS_UNIT_GL")), 
       sum(sys_op_opnsize("JOURNAL_ID")), count("JOURNAL_DATE"), sum(sys_op_opnsize("UNPOST_SEQ")) 
from "EMDBO"."PS_PROJ_RES_TMP" sample (  1.0000000000)  t 
/

---------------------
--TAB 6 - 12May17
---------------------

SELECT TRANS_DT, ACCOUNTING_DT, ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, A.RESOURCE_QUANTITY, A.RESOURCE_AMOUNT, BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, A.* 
FROM PS_PROJ_RESOURCE A
WHERE BUSINESS_UNIT = 'US004'
  AND PROJECT_ID = 'PP12MAY17'
ORDER BY DTTM_STAMP DESC;

SELECT PC_DISTRIB_STATUS , DST_ACCT_TYPE, BUDGET_HDR_STATUS, BUDGET_LINE_STATUS, A.* FROM PS_VCHR_ACCTG_LINE A 
WHERE BUSINESS_UNIT = 'US001' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP12MAY17';

SELECT REQ_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, LAST_DTTM_UPDATE, A.* FROM PS_REQ_HDR A WHERE BUSINESS_UNIT = 'US001' AND REQ_ID = '0000000174';

SELECT PO_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, A.* FROM PS_PO_HDR A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000364';
SELECT PO_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, A.* FROM PS_PO_HDR A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000365';

SELECT PC_DISTRIB_STATUS , A.* FROM PS_REQ_LN_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND REQ_ID = '0000000174' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP12MAY17';
SELECT PC_DISTRIB_STATUS , A.* FROM PS_PO_LINE_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000364' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP12MAY17';
SELECT PC_DISTRIB_STATUS , A.* FROM PS_PO_LINE_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000365' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP12MAY17';

--SOMEPP

--19MAY17
SELECT TRANS_DT, ACCOUNTING_DT, ANALYSIS_TYPE, REQ_ID, PO_ID, VOUCHER_ID, A.RESOURCE_QUANTITY, A.RESOURCE_AMOUNT, BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, A.* 
FROM PS_PROJ_RESOURCE A
WHERE BUSINESS_UNIT = 'US004'
  AND PROJECT_ID = 'PP19MAY17'
ORDER BY DTTM_STAMP DESC;

SELECT PC_DISTRIB_STATUS , DST_ACCT_TYPE, BUDGET_HDR_STATUS, BUDGET_LINE_STATUS, A.* FROM PS_VCHR_ACCTG_LINE A 
WHERE BUSINESS_UNIT = 'US001' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP19MAY17';

SELECT REQ_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, LAST_DTTM_UPDATE, A.* FROM PS_REQ_HDR A WHERE BUSINESS_UNIT = 'US001' AND REQ_ID = '0000000175';

SELECT PO_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, A.* FROM PS_PO_HDR A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000366';
SELECT PO_DT, ENTERED_DT, ACCOUNTING_DT, ACTIVITY_DATE, A.* FROM PS_PO_HDR A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000367';

SELECT PC_DISTRIB_STATUS , A.* FROM PS_REQ_LN_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND REQ_ID = '0000000175' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP19MAY17';
SELECT PC_DISTRIB_STATUS , A.* FROM PS_PO_LINE_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000366' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP19MAY17';
SELECT PC_DISTRIB_STATUS , A.* FROM PS_PO_LINE_DISTRIB A WHERE BUSINESS_UNIT = 'US001' AND PO_ID = '0000000367' AND BUSINESS_UNIT_PC = 'US004' AND PROJECT_ID = 'PP19MAY17';

--Oracle Analytic Functions
--Version 1
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC;

--Inline and ROWNUM
--Version 2
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, SIZE_MB, TABLESPACE_NAME
FROM (
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC)
WHERE ROWNUM <= 10;

--Version 3
--WITH Clause and ROWNUM
WITH ORDERED_QUERY AS 
(SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC)
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, SIZE_MB, TABLESPACE_NAME
FROM ORDERED_QUERY
WHERE ROWNUM <= 10;

--Version 4
--RANK
--Gaps in sequence
--Does not give "Top N Distinct Values"
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, SIZE_MB, TABLESPACE_NAME, VAL_RANK
FROM (SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME, RANK() OVER (ORDER BY BYTES DESC) AS VAL_RANK
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
)
WHERE VAL_RANK <= 10;


--Version 5
--DENSE_RANK
--Always gives "Top N Distinct Values"
--No Gap in Sequence
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, SIZE_MB, TABLESPACE_NAME, VAL_RANK
FROM (SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME, DENSE_RANK() OVER (ORDER BY BYTES DESC) AS VAL_RANK
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
)
WHERE VAL_RANK <= 10;

--Version 6
--ROW_NUMBER
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, SIZE_MB, TABLESPACE_NAME, VAL_ROW_NBR
FROM (SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME, ROW_NUMBER() OVER (ORDER BY BYTES DESC) AS VAL_ROW_NBR
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
)
WHERE VAL_ROW_NBR <= 10;

------------------------
------------------------
--30JUN2017
------------------------
------------------------

ALTER SESSION SET QUERY_REWRITE_ENABLED = TRUE;
ALTER SESSION SET query_rewrite_enabled = true;
ALTER SESSION SET query_rewrite_integrity = enforced;
ALTER SESSION SET optimizer_mode = all_rows;

ALTER MATERIALIZED VIEW PS_PRJRESOURCE_MVW ENABLE QUERY REWRITE;

ALTER MATERIALIZED VIEW PS_PP_PRJ_RESRC_MV ENABLE QUERY REWRITE;  


EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PRJRESOURCE_MVW', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('EMDBO', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);

exec dbms_mview.refresh('PS_PRJRESOURCE_MVW', 'F');
--exec dbms_mview.refresh('PS_PRJRESOURCE_MVW', 'C');
exec dbms_mview.refresh('PS_PP_PRJ_RESRC_MV', 'F');
--exec dbms_mview.refresh('PS_PP_PRJ_RESRC_MV', 'C');

SELECT BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID, SUM(RESOURCE_QUANTITY), SUM(RESOURCE_AMOUNT) 
FROM PS_PROJ_RESOURCE
WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP19MAY17'
GROUP BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID;

SELECT * FROM PS_PRJRESOURCE_MVW WHERE BUSINESS_UNIT IN ('US004', 'US005');
SELECT * FROM PS_PRJRESOURCE_MVW WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP19MAY17';

SELECT * FROM PS_PRJRESOURCE_MVW WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP23MAY17';
SELECT * FROM PS_PP_PRJ_RESRC_MV WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP23MAY17';

select column_name, data_default, virtual_column, hidden_column from dba_tab_cols where table_name = 'PS_PROJ_RESOURCE';


SELECT COUNT(*) FROM PS_PRJRESOURCE_MVW;

SELECT BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID, SUM(RESOURCE_QUANTITY), SUM(RESOURCE_AMOUNT) 
FROM PS_PROJ_RESOURCE
WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP19MAY17'
GROUP BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID;


SELECT BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID, SUM(RESOURCE_QUANTITY), SUM(RESOURCE_AMOUNT) 
FROM PS_PROJ_RESOURCE
WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP19MAY17'
GROUP BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID
HAVING SUM(RESOURCE_AMOUNT) > 10000;


SELECT BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID, SUM(RESOURCE_QUANTITY), SUM(RESOURCE_AMOUNT) 
FROM PS_PROJ_RESOURCE
WHERE BUSINESS_UNIT = 'US004' AND PROJECT_ID = 'PP24MAY17'
GROUP BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, RESOURCE_ID;


SELECT * FROM DBA_TAB_STATS_HISTORY WHERE TABLE_NAME = 'PS_PROJ_RESOURCE' ORDER BY STATS_UPDATE_TIME DESC;
SELECT * FROM DBA_TAB_STATS_HISTORY ORDER BY STATS_UPDATE_TIME DESC;

SELECT REC.BUILDSEQNO, REC.RECNAME, REC.RECDESCR,OBJECTOWNERID, TRIM(TO_CHAR(AUXFLAGMASK, 'XXXXXXXX')) AUXFLAGMASK ,
CASE SUBSTR(TRIM(TO_CHAR(AUXFLAGMASK, 'XXXXXXXX')) , 1, 1)
WHEN '1' THEN 'IDCMV-Immediate,OnDemand,Complete MV (REVIEW-DECIDE)'
WHEN '3' THEN 'IDFMV-Immediate,OnDemand,Fast MV (RIGHT-RECOMMENDED)'
WHEN '7' THEN 'ICFMV-Immediate,OnCommit,Fast MV (REVIEW-NOT RECOMENDED)'
WHEN '9' THEN 'DDCMV-Deffered,OnDemand,Complete MV (REVIEW-DECIDE)'
WHEN 'B' THEN 'DDFMV-Deffered,OnDemand,Fast MV (RIGHT-RECOMMENDED)'
WHEN 'F' THEN 'DCFMV-Deffered,OnCommit,Fast MV (REVIEW-NOT RECOMMENDED)' end ReviewDecision
FROM PSRECDEFN REC
WHERE REC.RECTYPE = 1
  AND BITAND(AUXFLAGMASK, 16777216) = 16777216 
ORDER BY REC.BUILDSEQNO;

ALTER SESSION SET query_rewrite_enabled = true;
ALTER SESSION SET query_rewrite_integrity = enforced;
ALTER SESSION SET optimizer_mode = all_rows;

ALTER MATERIALIZED VIEW PS_PP_PRJ_RES01_MV ENABLE QUERY REWRITE;
CREATE MATERIALIZED VIEW LOG ON PS_PROJ_RESOURCE WITH PRIMARY KEY,SEQUENCE, ROWID INCLUDING NEW VALUES;
SELECT * FROM PS_PP_PRJ_RES01_MV;
SELECT * FROM PS_PROJ_RESOURCE;

exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PROJ_RESOURCE', estimate_percent=>null, cascade=> true, method_opt=> 'FOR ALL COLUMNS SIZE 1');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PP_PRJ_RES01_MV', estimate_percent=>null, cascade=> true, method_opt=> 'FOR ALL COLUMNS SIZE 1');

--Run these for Transaction Tables (Incomplete)
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PROJ_RESOURCE', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PP_PRJ_RES01_MV', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PROJ_AN_GRP_MAP', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_SET_CNTRL_REC', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PO_LINE_DISTRIB', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_VCHR_ACCTG_LINE', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_REQ_LN_DISTRIB', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');

SELECT * FROM DBA_TAB_STATS_HISTORY ORDER BY STATS_UPDATE_TIME DESC;

SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_PP_PRJ_RES01_MV';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_PROJ_AN_GRP_MAP';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_SET_CNTRL_REC';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_PO_LINE_DISTRIB';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_VCHR_ACCTG_LINE';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_REQ_LN_DISTRIB';
exec dbms_mview.refresh('PS_PP_PRJ_RES01_MV', 'C');
--If the MV is STALE, refresh it
SELECT UMV.REWRITE_ENABLED, UMV.REWRITE_CAPABILITY, UMV.REFRESH_METHOD, UMV.REFRESH_MODE, UMV.STALENESS, UMV.STALE_SINCE, umv.* FROM dba_mviews umv;

SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC;

SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_NAME IN ('PS_PP_PRJ_RES01_MV', 'PS_PROJ_RESOURCE')
AND SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC;


select blocks, lf_blks, btree_space, pct_used from index_stats;

ALTER TABLE PS_PROJ_RESOURCE enable row movement;
ALTER TABLE PS_PROJ_RESOURCE shrink space compact;
--Reset the HWM
ALTER TABLE PS_PROJ_RESOURCE shrink space;

SELECT TABLE_NAME,ROUND((BLOCKS*8),2)||'kb' "size" FROM USER_TABLES WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
--Query to find Actual data in Table
SELECT TABLE_NAME,ROUND((NUM_ROWS*AVG_ROW_LEN/1024),2)||'kb' "size" FROM USER_TABLES WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT COUNT (DISTINCT DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) "used blocks" FROM PS_PROJ_RESOURCE;

SELECT name, bytes/1024/1024 AS size_mb FROM v$datafile ORDER BY 2 DESC;

ALTER DATABASE DATAFILE '/slot/ems11873/oracle/db/apps_st/data/e92pcvol/data/psmatvw.dbf' RESIZE 124M;
ALTER TABLESPACE PSMATVW COALESCE;
ALTER DATABASE DATAFILE '/slot/ems11873/oracle/db/apps_st/data/e92pcvol/data/psmatvw.dbf' RESIZE 24M;

SELECT tablespace_name, size_mb, free_mb, max_size_mb, max_free_mb, TRUNC((max_free_mb/max_size_mb) * 100) AS free_pct,
       RPAD(' '|| RPAD('X',ROUND((max_size_mb-max_free_mb)/max_size_mb*10,0), 'X'),11,'-') AS used_pct
FROM (SELECT a.tablespace_name, b.size_mb, a.free_mb, b.max_size_mb, a.free_mb + (b.max_size_mb - b.size_mb) AS max_free_mb
        FROM (SELECT tablespace_name, TRUNC(SUM(bytes)/1024/1024) AS free_mb
                FROM dba_free_space GROUP BY tablespace_name) a,
               (SELECT tablespace_name, TRUNC(SUM(bytes)/1024/1024) AS size_mb, TRUNC(SUM(GREATEST(bytes,maxbytes))/1024/1024) AS max_size_mb
                FROM dba_data_files GROUP BY tablespace_name) b
        WHERE  a.tablespace_name = b.tablespace_name
       )
ORDER BY FREE_PCT, tablespace_name;

SELECT segment_type, segment_name, COUNT(*)
FROM dba_extents
--WHERE owner = 'RECLAIM_USER'
GROUP BY segment_type, segment_name
ORDER BY segment_type, segment_name;

SELECT * FROM PSRECTBLSPC WHERE DDLSPACENAME = 'PSMATVW';

select file_id, block_id, blocks, bytes, 'Free' from dba_free_space
where tablespace_name = 'PSMATVW'
and file_id = 189
--and rownum < 7
order by block_id desc;

select bytes/1024/1024 from dba_data_files where file_id = 189;
alter database datafile 189 resize 9000M;

--TRUNCATE TABLE COMMAND TESTING
analyze table PS_PP_PROJ_RES COMPUTE STATISTICS;

SELECT num_rows, blocks, empty_blocks, A.*
FROM user_tables A
WHERE table_name = 'PS_PP_PROJ_RES';

--Default is DROP STORAGE
TRUNCATE TABLE PS_PP_PROJ_RES REUSE STORAGE;
