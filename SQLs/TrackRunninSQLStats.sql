--“Subqueries perform better when you use IN rather than EXISTS.
--Oracle recommends using the IN clause if the subquery has the selective WHERE clause.
--If the parent query contains the selective WHERE clause, use the EXISTS clause rather than the IN clause.”
--“Whether you use IN or EXISTS depends on the sizes of the driving table (the outer table referenced in the SELECT, UPDATE, or DELETE) 
--and the size of the result set in the subquery.
--Using IN is most likely better if the results of the subquery are small or is a list of constants.
--However, using EXISTS may run a lot more efficiently since the implicit JOIN may take advantage of indexes.”
--https://hoopercharles.wordpress.com/2009/12/29/which-is-most-efficient-when-deleting-rows-exists-in-or-a-view/


-------------------
--Check Tablespace
-------------------
--You need elevated access to run this query
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
   group by tablespace_name
   ) df,
   (select tablespace_name, round(sum(bytes) / 1048576) FreeSpace
   from dba_free_space
   group by tablespace_name
   ) fs
where df.tablespace_name = fs.tablespace_name
ORDER BY df.totalspace DESC;

--Version 2
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

select A.file_id, A.block_id, A.blocks, A.bytes, tablespace_name, bytes/1024/1024 AS size_mb
from dba_free_space A 
--where A.tablespace_name = 'PSMATVW' 
  --and file_id = 189
  --and rownum < 7
--order by A.block_id desc;
order by size_mb desc;

--Check Datafile size
SELECT name, bytes/1024/1024 AS size_mb FROM v$datafile ORDER BY 2 DESC;

SELECT A.name, bytes/1024/1024 AS size_mb, file#, blocks, block_size, create_bytes/1024/1024 AS create_siz_mb, A.* FROM v$datafile A ORDER BY 2 DESC;

--Alter Datafile
ALTER DATABASE DATAFILE '/opt/oracle/psft/db/oradata/EP92U021/aucapp.dbf' RESIZE 24M;

--Check which records belong to that tablespace
SELECT * FROM SYSADM.PSRECTBLSPC WHERE DDLSPACENAME = 'LCAPP';

select file_id, block_id, blocks, bytes, 'Free' from dba_free_space where tablespace_name = 'PSMATVW' and file_id = 189
--and rownum < 7
order by block_id desc;

select bytes/1024/1024 from dba_data_files where file_id = 189;

-----------------
--Gather Stats
--Reset HWM
-----------------
BEGIN
  --DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => USER,TABNAME => 'PS_PROJ_RESOURCE',FORCE=>TRUE,CASCADE => TRUE,DEGREE => 4);
  --DBMS_STATS.GATHER_TABLE_STATS ('emdbo', 'PS_PROJ_RESOURCE', ESTIMATE_PERCENT=>1, METHOD_OPT=> 'FOR ALL INDEXED COLUMNS SIZE 1',CASCADE=>TRUE);
  DBMS_STATS.GATHER_TABLE_STATS ('FM92P19', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);
end;

--This is an old command
--ANALYZE TABLE PS_PROJ_RESOURCE COMPUTE STATISTICS;
EXEC DBMS_STATS.GATHER_TABLE_STATS ('FM92P19', 'PS_PROJ_RESOURCE');
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>USER,TABNAME=>'PS_PROJ_RESOURCE');
--EXEC DBMS_STATS.DELETE_TABLE_STATS(OWNNAME=>user,TABNAME=>'PS_GPFR_RSLT_TMP_P');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('FM92P19', 'PS_PROJ_RESOURCE', ESTIMATE_PERCENT=>1, METHOD_OPT=> 'FOR ALL INDEXED COLUMNS SIZE 1',CASCADE=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS ('FM92P19', 'PS_PROJ_RESOURCE', estimate_percent=> dbms_stats.auto_sample_size, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 1',cascade=>TRUE);

--Run these for Transaction Tables
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PROJ_RESOURCE', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PP_PRJ_RES01_MV', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_PROJ_AN_GRP_MAP', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');
exec dbms_stats.gather_table_stats(ownname=>null, tabname=>'PS_SET_CNTRL_REC', estimate_percent=>100, cascade=> true, method_opt=> 'FOR ALL INDEXED COLUMNS SIZE 254');

--Query to find Table size with fragmentation	
SELECT TABLE_NAME,ROUND((BLOCKS*8),2)||'kb' "size" FROM USER_TABLES WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
--Query to find Actual data in Table
SELECT TABLE_NAME,ROUND((NUM_ROWS*AVG_ROW_LEN/1024),2)||'kb' "size" FROM USER_TABLES WHERE TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT COUNT (DISTINCT DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) "used blocks" FROM PS_PROJ_RESOURCE;

--How to reset HWM
--First Enable Row Movement
--Second Shrink Space
--To reclaim space, use the shrink command to re-organize data
ALTER TABLE FM92P19.PS_PROJ_RESOURCE enable row movement;
--Re-arrange rows 
ALTER TABLE FM92P19.PS_PROJ_RESOURCE shrink space compact;
--Reset the HWM
ALTER TABLE FM92P19.PS_PROJ_RESOURCE shrink space;


---------------------------------
--Detailed Stats for an SQLTable
---------------------------------
SET LINESIZE 300
SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE
  CURSOR cu_tables IS
    SELECT a.owner,
           a.table_name
    FROM   ALL_TABLES A
    WHERE  A.TABLE_NAME = DECODE(UPPER('PS_PROJ_RESOURCE'),'ALL',A.TABLE_NAME,UPPER('PS_PROJ_RESOURCE'))
    AND    a.owner      = Upper('FM92P19') 
    AND    a.partitioned='NO'
    AND    a.logging='YES'
order by table_name;

  op1  NUMBER;
  op2  NUMBER;
  op3  NUMBER;
  op4  NUMBER;
  op5  NUMBER;
  op6  NUMBER;
  op7  NUMBER;
BEGIN

  Dbms_Output.Disable;
  Dbms_Output.Enable(1000000);
  Dbms_Output.Put_Line('TABLE                             UNUSED BLOCKS     TOTAL BLOCKS  HIGH WATER MARK');
  Dbms_Output.Put_Line('------------------------------  ---------------  ---------------  ---------------');
  FOR cur_rec IN cu_tables LOOP
    Dbms_Space.Unused_Space(cur_rec.owner,cur_rec.table_name,'TABLE',op1,op2,op3,op4,op5,op6,op7);
    Dbms_Output.Put_Line(RPad(cur_rec.table_name,30,' ') ||
                         LPad(op3,15,' ')                ||
                         LPad(op1,15,' ')                ||
                         LPad(Trunc(op1-op3-1),15,' ')); 
  END LOOP;

END;
/


select table_name, constraint_name,
      cname1 || nvl2(cname2,','||cname2,null) ||
      nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
      nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
      nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null)
             columns
   from ( select b.table_name,
                 b.constraint_name,
                 max(decode( position, 1, column_name, null )) cname1,
                 max(decode( position, 2, column_name, null )) cname2,
                 max(decode( position, 3, column_name, null )) cname3,
                 max(decode( position, 4, column_name, null )) cname4,
                 max(decode( position, 5, column_name, null )) cname5,
                 max(decode( position, 6, column_name, null )) cname6,
                 max(decode( position, 7, column_name, null )) cname7,
                 max(decode( position, 8, column_name, null )) cname8,
                 count(*) col_cnt
            from (select substr(table_name,1,30) table_name,
                         substr(constraint_name,1,30) constraint_name,
                         substr(column_name,1,30) column_name,
                         position
                    from user_cons_columns ) a,
                 user_constraints b
           where a.constraint_name = b.constraint_name
             and b.constraint_type = 'R'
           group by b.table_name, b.constraint_name
        ) cons
  where col_cnt > ALL
          ( select count(*)
              from user_ind_columns i
             where i.table_name = cons.table_name
               and i.column_name in (cname1, cname2, cname3, cname4,
                                     cname5, cname6, cname7, cname8 )
               and i.column_position <= cons.col_cnt
             group by i.index_name
          )
/
----------------------
--Find the current SQL
----------------------

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

select b.sid,b.status,b.last_call_et,b.program,c.sql_id,c.sql_text
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

--Note the SQL_ID for the row where PROGRAM = PSAESRV
SELECT CHILD_NUMBER, CPU_TIME, ELAPSED_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, PLSQL_EXEC_TIME, ROWS_PROCESSED, ACTION,  A.*
FROM V$SQL A WHERE  SQL_ID = '7sks5hwcj2w2c' --Put your SQL_ID here
/

--------------------
--Long Running SQLs
--------------------
--Make note of SQL_ID for transactions where PERCENT_DONE is less than 100
select sid
      ,serial#
      ,opname
      ,target
      ,round(sofar/totalwork*100,2) as percent_done
      ,start_time
      ,last_update_time
      ,time_remaining
      ,elapsed_seconds
      ,sofar
      ,totalwork
      ,sql_id
      ,sql_plan_operation
      ,sql_plan_options
	  ,message
	  ,sql_plan_hash_value
from 
       v$session_longops ORDER BY LAST_UPDATE_TIME DESC
/

--Take the SQL_ID returned by the above query and identify the long running SQL
SELECT CHILD_NUMBER, CPU_TIME, ELAPSED_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, PLSQL_EXEC_TIME, ROWS_PROCESSED, ACTION,  A.*
FROM V$SQL A WHERE  SQL_ID = '7sks5hwcj2w2c' --Put your SQL_ID here
/

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


--Longops
--Version 1
COLUMN sid FORMAT 999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.sid, s.serial#, s.machine, opname, sql_id, sql_plan_operation, sql_plan_options
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct
FROM   v$session s, v$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
/

--Version 2
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
AND    (ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) <> '0:0' OR ROUND(sl.sofar/sl.totalwork*100, 2) <> 100.00)
/

--LAST_CALL_ET - represents the elapsed time (in seconds) since the session has become active
select ses.sid, ses.serial#, ses.username, ses.machine, ses.program, ses.status, ses.last_call_et, sql.hash_value, sql.sql_text
from v$session ses, v$sql sql
where ses.sql_hash_value = sql.hash_value
and ses.type = 'USER'
and ses.status = 'ACTIVE';

--Includes session, sql, and session_longops
select ses.sid, ses.serial#, ses.username, ses.machine, ses.program, ses.status, ses.last_call_et, V.time_remaining, V.elapsed_seconds, V.sofar, V.totalwork, V.opname, 
       V.target, V.sql_id, 
       ROUND(V.elapsed_seconds/60) || ':' || MOD(V.elapsed_seconds,60) elapsed,
       ROUND(V.time_remaining/60) || ':' || MOD(V.time_remaining,60) remaining,
       ROUND(V.sofar/V.totalwork*100, 2) progress_pct,
       sql.hash_value, V.sql_plan_operation, V.sql_plan_options, V.message, V.SQL_plan_hash_value, V.start_time, V.last_update_time, sql.sql_text
from (v$session ses LEFT OUTER JOIN v$session_longops V ON ses.sid = V.sid and ses.serial# = V.serial# and ses.sql_hash_value = V.sql_hash_value), v$sql sql
where ses.sql_hash_value = sql.hash_value
  and ses.type = 'USER'
  and ses.status = 'ACTIVE';

----------------------
--Find Locked Objects
----------------------
SELECT O.OBJECT_NAME, S.SID, S.SERIAL#, P.SPID, S.PROGRAM, S.USERNAME, S.MACHINE,S.PORT , S.LOGON_TIME,SQ.SQL_FULLTEXT --Make note of sid,serial#
FROM V$LOCKED_OBJECT L, DBA_OBJECTS O, V$SESSION S, V$PROCESS P, V$SQL SQ 
WHERE L.OBJECT_ID = O.OBJECT_ID 
  AND L.SESSION_ID = S.SID AND S.PADDR = P.ADDR 
  AND S.SQL_ADDRESS = SQ.ADDRESS;

--------------------------------  
--Identify Session to be killed
--------------------------------
SET LINESIZE 100
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN program FORMAT A45

SELECT s.inst_id,
       s.sid, --This is needed
       s.serial#, --This is needed
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND';

----------------------------------------------------------------------
--Make sure you login with elevated access, this is highly restricted
----------------------------------------------------------------------
ALTER SYSTEM KILL SESSION '471,55579';

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

SELECT * FROM V$SQL_PLAN;
SELECT * FROM V$SQL_PLAN_STATISTICS;
SELECT * FROM V$SQL_PLAN_STATISTICS_ALL;

--Adaptive Advanced Execution Plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'+ALLSTATS'));
SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY_CURSOR (FORMAT=>'ALLSTATS LAST'));
--Replace the SQL_ID below with the one returned by the above query
SELECT * FROM v$sql_plan WHERE SQL_ID = 'c78pjj98ft2mb';


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

SELECT plan_table_output
FROM table(DBMS_XPLAN.DISPLAY_CURSOR (FORMAT=>'ALLSTATS LAST ADAPTIVE'));

--Find the High Water Mark (HWM) for a TABLE
--Version 1
select
    a.owner,
    a.table_name,
    b.blocks                        alcblks,
    a.blocks                        usdblks,
    (b.blocks-a.empty_blocks-1)     hgwtr
from dba_tables a, dba_segments b
where a.table_name = b.segment_name
  and a.owner = b.owner
  --and a.owner in ('SYS','SYSADM')
  and a.blocks <> (b.blocks-a.empty_blocks-1)
  and a.table_name = 'PS_PROJ_RESOURCE'
order by 1,2;

--Version 2
select
    a.owner,
    b.SEGMENT_TYPE,
    a.table_name,
    b.blocks                        alcblks,
    a.blocks                        usdblks,
    (b.blocks-a.empty_blocks-1)     hgwtr,
    a.num_rows,
    a.blocks,
    a.*, b.*
from dba_tables a, dba_segments b
where a.table_name = b.segment_name
  and a.owner = b.owner
  --and a.owner in ('SYS','SYSADM')
  and a.blocks <> (b.blocks-a.empty_blocks-1)
  and a.table_name = 'PS_PROJ_RESOURCE'
order by 1,2;

--In case you are not able to run the Adaptive Execution Plan, run the below GRANT STATEMENTS
GRANT SELECT ON V_$SESSION TO emdbo
GRANT SELECT ON V_$SQL TO emdbo
GRANT SELECT ON V_$SQL_PLAN TO emdbo
GRANT SELECT ON V_$SQL_PLAN_STATISTICS_ALL TO emdbo

----------------------------------------------------
--Purge Rows for Cancelled/No Success Runs of an AE
----------------------------------------------------
SELECT * FROM PS_AERUNCONTROL WHERE OPRID = 'VP1' AND RUN_CNTL_ID LIKE 'AFTER%';
SELECT * FROM PS_AETEMPTBLMGR WHERE OPRID = 'VP1' AND RUN_CNTL_ID LIKE 'AFTER%';

DELETE FROM PS_AETEMPTBLMGR WHERE PROCESS_INSTANCE IN (88009, 88019, 88020, 88021, 88022, 88026, 88027, 88029, 88030, 88032, 88033);
DELETE FROM PS_AERUNCONTROL WHERE PROCESS_INSTANCE IN (88009, 88019, 88020, 88021, 88022, 88026, 88027, 88029, 88030, 88032, 88033);
DELETE FROM PS_AERUNCONTROLPC WHERE PROCESS_INSTANCE IN (88009, 88019, 88020, 88021, 88022, 88026, 88027, 88029, 88030, 88032, 88033);

--To make the optimizer believe they are "BIG"
--Use this only for testing
begin
dbms_stats.set_table_stats
( user, 'FOOBAR', numrows=>1000000, numblks=>100000 );
dbms_stats.set_table_stats
( 'SYSADM', 'PS_DEPT_TBL', numrows=>1000000, numblks=>100000 );
end; 
/

--Find Size of Objects in DB
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, ROUND(BYTES/(1024*1024),2) SIZE_MB, TABLESPACE_NAME 
FROM DBA_SEGMENTS 
WHERE SEGMENT_TYPE IN ('CLUSTER', 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 
                       'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION', 'NESTED TABLE', 'ROLLBACK', 'SYSTEM STATISTICS', 'TYPE2 UNDO')                       
ORDER BY BYTES DESC;

---------------------------------
--Tony Hasler's Book Listing 4-4
---------------------------------
--This is much easier to read than EXPLAIN PLAN table
SELECT DEPTH, LPAD (' ', DEPTH) || operation operation, options, object_name, time "EST TIME (Secs)", 
       last_elapsed_time / 1000000 "ACTUAL TIME (Secs)", CARDINALITY "EST ROWS", last_output_rows "Actual Rows"
FROM v$sql_plan_statistics_all
WHERE sql_id = '199v14ct2bq0k' 
  AND child_number = 0
ORDER BY id;

--Version 2
--Additional column added OPERATION_2
SELECT DEPTH, LPAD (' ', DEPTH) || operation operation, options, object_name, time "EST TIME (Secs)", 
       last_elapsed_time / 1000000 "ACTUAL TIME (Secs)", CARDINALITY "EST ROWS", last_output_rows "ACTUAL ROWS",
       LPAD(' ',depth)||OPERATION||' '||OPTIONS||' '||OBJECT_NAME||DECODE(PARTITION_START,NULL,' ',':')||TRANSLATE(PARTITION_START,'(NRUMBE','(NR')||
       DECODE(PARTITION_STOP,NULL,' ','-')||TRANSLATE(PARTITION_STOP,'(NRUMBE','(NR') operation_2
FROM v$sql_plan_statistics_all
WHERE sql_id = '199v14ct2bq0k' 
  AND child_number = 0
ORDER BY id;

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
order by P.CHILD_NUMBER, p.id
/

--------------------------------------------
--Statistics on Tables, Indexes and Columns
--------------------------------------------
SELECT * FROM DBA_TABLES WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_STATISTICS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_COL_STATISTICS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';
SELECT * FROM DBA_TAB_HISTOGRAMS WHERE OWNER = 'SYSADM' AND TABLE_NAME = 'PS_PROJ_RESOURCE';


--DO NOT USE THIS IN PRODUCTION ENVIRONMENT
exec DBMS_STATS.SET_COLUMN_STATS('SYSADM','PS_PROJ_RESOURCE','BUSINESS_UNIT',DISTCNT=>1000);

SELECT * FROM V$SQL_MONITOR;
SELECT * FROM V$SQL_PLAN_MONITOR WHERE sql_id = '199v14ct2bq0k';
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE sql_id = '199v14ct2bq0k';

SELECT HASH_VALUE, CHILD_NUMBER, CPU_TIME, ELAPSED_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, PLSQL_EXEC_TIME, ROWS_PROCESSED, ACTION,  A.*
FROM V$SQL A WHERE SQL_ID = '199v14ct2bq0k';

SELECT * FROM v$session WHERE SQL_ID = '199v14ct2bq0k';

--TOAD Blog - Regular and Functional Indexes
SELECT ASCIISTR(CHR(TO_NUMBER('44','xx'))) "44", 
ASCIISTR(CHR(TO_NUMBER('45','xx'))) "45",
ASCIISTR(CHR(TO_NUMBER('49','xx'))) "49",
ASCIISTR(CHR(TO_NUMBER('42','xx'))) "42",
ASCIISTR(CHR(TO_NUMBER('59','xx'))) "59" FROM DUAL;

SELECT ASCIISTR(CHR(TO_NUMBER('47','xx'))) "47", 
ASCIISTR(CHR(TO_NUMBER('4f','xx'))) "4f",
ASCIISTR(CHR(TO_NUMBER('4d','xx'))) "4d",
ASCIISTR(CHR(TO_NUMBER('45','xx'))) "45",
ASCIISTR(CHR(TO_NUMBER('5a','xx'))) "5a" FROM DUAL; 

--David Kurtz
--http://blog.psftdba.com/2007/10/using-vsessionlongops-to-find-long.html
SELECT l.*, NVL(s.sql_text, perfstat.get_sqltext(l.sql_hash_value)) sql_text
FROM (
  SELECT l.target, l.operation, l.sql_hash_value, SUM(secs) secs, SUM(execs) execs
  FROM (
    SELECT l.sid, l.serial#, l.sql_address, l.sql_hash_value, l.target, l.operation, MAX(l.last_update_time-l.start_time)*86400 secs, 
	       COUNT(*) execs, SUM(totalwork) totalwork
    FROM (
      SELECT l.*, SUBSTR(l.message,1,instr(l.message,':',1,1)-1) operation 
      FROM   v$session_longops l) l
    GROUP BY l.sid, l.serial#, l.sql_address, l.sql_hash_value, l.target, l.operation
    ) l
  GROUP BY l.target, l.operation, l.sql_hash_value
  ) l
  LEFT OUTER JOIN v$sql s ON s.hash_value = l.sql_hash_value
--AND s.address = l.sql_address
AND  s.child_number = 0
ORDER BY secs desc;

Alter System flush buffer_cache; -- flush this to see some physical reads
Alter system flush shared_pool
