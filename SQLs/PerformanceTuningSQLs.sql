-- flush this to see some physical reads
ALTER System flush buffer_cache;
ALTER system flush shared_pool;
ALTER SESSION SET optimizer_mode = all_rows;
--Set this to FALSE on Oracle 12cR1 (Doc ID - 1100831.1)
ALTER SESSION SET OPTIMIZER_ADAPTIVE_FEATURES = FALSE;
--Make sure all 3 are set to FALSE
SELECT * FROM v$parameter WHERE NAME IN ('_gby_hash_aggregation_enabled', '_unnest_subquery', 'OPTIMIZER_ADAPTIVE_FEATURES') ORDER BY NAME;
 
select index_name, blevel + 1, A.* from user_indexes A order by 2 DESC NULLS LAST;
exec dbms_stats.gather_schema_stats('EMDBO');
 
exec dbms_stats.gather_table_stats(ownname=>'EMDBO', tabname=>'PS_PROJ_RESOURCE', estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, cascade=>TRUE, method_opt=> 'FOR ALL COLUMNS SIZE AUTO', no_invalidate=>FALSE);
exec dbms_stats.gather_table_stats(ownname=>'EMDBO', tabname=>'PS_PROJ_RES_TMP', estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, cascade=>TRUE, method_opt=> 'FOR ALL COLUMNS SIZE AUTO', no_invalidate=>FALSE);
exec dbms_stats.gather_table_stats(ownname=>'EMDBO', tabname=>'PS_PROJ_RES_DEL', estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, cascade=>TRUE, method_opt=> 'FOR ALL COLUMNS SIZE AUTO', no_invalidate=>FALSE);
 
--UPDATE PSPRCSRQST SET RETRYCOUNT='-1' WHERE PRCSINSTANCE = 144321;
--UPDATE PSPRCSQUE SET RETRYCOUNT='-1' WHERE PRCSINSTANCE = 144321;
 
--Version 3
--Added Predicates, OBJECT_TYPE, LAST_STARTS, OPTIMIZER columns
SELECT DEPTH, LPAD (' ', DEPTH) || operation operation, options, object_name, time "EST TIME (Secs)", OPTIMIZER, LAST_STARTS,
       last_elapsed_time / 1000000 "ACTUAL TIME (Secs)", CARDINALITY "EST ROWS", last_output_rows "ACTUAL ROWS",
       LPAD(' ',depth)||OPERATION||' '||OPTIONS||' '||OBJECT_NAME||DECODE(PARTITION_START,NULL,' ',':')||TRANSLATE(PARTITION_START,'(NRUMBE','(NR')||
       DECODE(PARTITION_STOP,NULL,' ','-')||TRANSLATE(PARTITION_STOP,'(NRUMBE','(NR') operation_2, OBJECT_TYPE, ACCESS_PREDICATES, FILTER_PREDICATES
FROM v$sql_plan_statistics_all
--WHERE sql_id = 'aptcgpbtgguv3'
WHERE sql_id = '3j7dcjwvc9p7n'
  AND child_number = 0
ORDER BY id;
 
--------------------------------------------
--Statistics on Tables, Indexes and Columns
--------------------------------------------
SELECT * FROM DBA_TABLES WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_STATISTICS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_COL_STATISTICS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_HISTOGRAMS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED, GLOBAL_STATS, A.* FROM DBA_TABLES A WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
 
SELECT * FROM USER_TABLES WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM USER_TAB_HISTOGRAMS WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
 
----------------------------------
--Tuning by Cardinality Feedback
----------------------------------
set define '~'
define hv=~1
set verify off echo off feed off
set linesize 300 pagesize 3000
 
col hv head 'hv' noprint
col "cn" for 90 print
col "card" for 999,999,990
col "ROWS" for 999,999,990
col "ELAPSED" for 99,990.999
col "CPU" for 99,990.999
col CR_GETS for 99,999,990
col CU_GETS for 99,999,990
col READS for 9,999,990
col WRITES for 99,990
break on hv skip 0 on "cn" skip 0
SELECT P.HASH_VALUE hv, P.CHILD_NUMBER "cn", to_char(p.id,'990')||decode(access_predicates,null,null,'A')||decode(filter_predicates,null,null,'F') id, P.COST "cost",
       P.CARDINALITY "card", LPAD(' ',depth)||P.OPERATION||' '||P.OPTIONS||' '||P.OBJECT_NAME||DECODE(P.PARTITION_START,NULL,' ',':')||
       TRANSLATE(P.PARTITION_START,'(NRUMBE','(NR')||DECODE(P.PARTITION_STOP,NULL,' ','-')||TRANSLATE(P.PARTITION_STOP,'(NRUMBE','(NR') "operation", P.POSITION "pos",
       (SELECT S.LAST_OUTPUT_ROWS FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS = P.ADDRESS and s.hash_value = p.hash_value
                                                                 and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "ROWS",
       (SELECT ROUND(S.LAST_ELAPSED_TIME/1000000,2) FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS = P.ADDRESS  and s.hash_value = p.hash_value
                                                                                            and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "ELAPSED",
       (SELECT S.LAST_CR_BUFFER_GETS FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS=P.ADDRESS and s.hash_value = p.hash_value
                                                                    and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "CR_GETS",
       (SELECT S.LAST_CU_BUFFER_GETS FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS = P.ADDRESS and s.hash_value = p.hash_value
                                                                    and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "CU_GETS",
       (SELECT S.LAST_DISK_READS FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS = P.ADDRESS and s.hash_value = p.hash_value
                                                                and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "READS",
       (SELECT S.LAST_DISK_WRITES FROM V$SQL_PLAN_STATISTICS S WHERE S.ADDRESS = P.ADDRESS and s.hash_value = p.hash_value
                                                                 and s.child_number = p.child_number AND S.OPERATION_ID = P.ID) "WRITES"
FROM V$SQL_PLAN P
where p.hash_value = ~hv
order by P.CHILD_NUMBER, p.id;
 
--Find Size of Objects in DB
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME
FROM DBA_SEGMENTS
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION',
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                      
ORDER BY BYTES DESC;
 
--Monitor Long Running Queries
SELECT VSQL.sql_text, ses.sid, ses.serial#, ses.username, ses.machine, ses.program, ses.status, ses.last_call_et, V.time_remaining, V.elapsed_seconds, V.sofar, V.totalwork, V.opname, V.target, V.sql_id,
       ROUND(V.elapsed_seconds/60) || ''':''' || MOD(V.elapsed_seconds, 60) elapsed, ROUND(V.time_remaining/60) || ''':''' || MOD(V.time_remaining, 60) remaining, ROUND(V.sofar/V.totalwork*100, 2) progress_pct,
       VSQL.hash_value, V.sql_plan_operation, V.sql_plan_options, V.message, V.SQL_plan_hash_value, V.start_time, V.last_update_time
FROM (V$SESSION ses LEFT OUTER JOIN V$SESSION_LONGOPS V ON ses.sid = V.sid AND ses.serial# = V.serial# AND ses.sql_hash_value = V.sql_hash_value), V$SQL VSQL
WHERE ses.sql_hash_value = VSQL.hash_value
  AND ses.type = 'USER'
  AND ses.status = 'ACTIVE';
--Explain Plan
EXPLAIN PLAN FOR
--Put your SQL here;
 
--Basic Execution Plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
--ALL
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('','', 'ALL'));
--TYPICAL
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'', 'TYPICAL'));
SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY());
 
-----------------------------------------
--Active sessions for more than one hour
-----------------------------------------
SELECT USERNAME, machine, inst_id, sid, serial#, PROGRAM, SQL_ID, MODULE, ACTION, BLOCKING_SESSION_STATUS,
       to_char(logon_time,'dd-mm-yy hh:mi:ss AM')"Logon Time", ROUND((SYSDATE-LOGON_TIME)*(24*60),1) as MINUTES_LOGGED_ON,
       ROUND(LAST_CALL_ET/60,1) as Minutes_FOR_CURRENT_SQL
FROM gv$session
WHERE STATUS='ACTIVE'
  AND USERNAME IS NOT NULL
  AND ROUND((SYSDATE-LOGON_TIME)*(24*60),1) > 60
ORDER BY MINUTES_LOGGED_ON DESC;
 
--LAST_CALL_ET - represents the elapsed time (in seconds) since the session has become active
select ses.sid, ses.serial#, ses.username, ses.machine, ses.program, ses.status, ses.last_call_et, sql.hash_value, sql.sql_text
from v$session ses, v$sql sql
where ses.sql_hash_value = sql.hash_value
and ses.type = 'USER'
and ses.status = 'ACTIVE';
 
--Enable Row Movement and reset HWM
ALTER TABLE PS_PROJ_RESOURCE enable row movement;
ALTER TABLE PS_PROJ_RESOURCE shrink space compact;
--Reset the HWM
ALTER TABLE PS_PROJ_RESOURCE shrink space;
 
--Use HINT GATHER_PLAN_STATISTICS
SELECT /*+ GATHER_PLAN_STATISTICS */ OPRID, A.*
 FROM SYSADM.PSOPRDEFN A
 WHERE OPRID = 'VP1';
  
--On 12cR1, make use of this statement
SELECT plan_table_output
FROM table(DBMS_XPLAN.DISPLAY_CURSOR (FORMAT=>'ALLSTATS LAST'));
 
--Don't use this on 12cR1
--Safe to use from12cR2 onwards
SELECT plan_table_output
FROM table(DBMS_XPLAN.DISPLAY_CURSOR (FORMAT=>'ALLSTATS LAST ADAPTIVE'));
 
SELECT /*+ GATHER_PLAN_STATISTICS */ BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID, SUM(RESOURCE_QUANTITY), SUM(RESOURCE_AMOUNT)
FROM SYSADM.PS_PROJ_RESOURCE A
WHERE BUSINESS_UNIT IN ('US001', 'US004', 'US005')
GROUP BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID
ORDER BY BUSINESS_UNIT, PROJECT_ID, ACTIVITY_ID;
 
SELECT plan_table_output
FROM table(DBMS_XPLAN.DISPLAY_CURSOR (FORMAT=>'ALLSTATS LAST'));
