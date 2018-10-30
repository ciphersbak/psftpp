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
