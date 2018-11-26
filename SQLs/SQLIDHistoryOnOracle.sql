--How to find SQL,SQL_ID history on Oracle
--Session related Queries

--Last/Latest Running SQL
-----------------------
set pages 50000 lines 32767
col "Last SQL" for a100
SELECT t.inst_id,s.username, s.sid, s.serial#,t.sql_id,t.sql_text "Last SQL"
FROM gv$session s, gv$sqlarea t
WHERE s.sql_address =t.address AND
s.sql_hash_value =t.hash_value
/

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

--Last/Latest Running SQL
----------------------- 
set pages 50000 lines 32767
select inst_id,sample_time,session_id,session_serial#,sql_id from gv$active_session_history
where sql_id is not null 
order by 1 desc
/

--SQLs Running from longtime
--------------------------
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi';
set pages 50000 lines 32767
col target format a25
col opname format a40
select sid
      ,opname
      ,target
      ,round(sofar/totalwork*100,2)   as percent_done
      ,start_time
      ,last_update_time
      ,time_remaining
from 
       v$session_longops
/

--Active Sessions running for more than 1 hour
---------------------------------------------
set pages 50000 lines 32767
col USERNAME for a10
col MACHINE for a15
col PROGRAM for a40

SELECT USERNAME,machine,inst_id,sid,serial#,PROGRAM,
to_char(logon_time,'dd-mm-yy hh:mi:ss AM')"Logon Time",
ROUND((SYSDATE-LOGON_TIME)*(24*60),1) as MINUTES_LOGGED_ON,
ROUND(LAST_CALL_ET/60,1) as Minutes_FOR_CURRENT_SQL
From gv$session
WHERE STATUS='ACTIVE'
AND USERNAME IS NOT NULL and ROUND((SYSDATE-LOGON_TIME)*(24*60),1) > 60
ORDER BY MINUTES_LOGGED_ON DESC;

--Session details associated with SID and Event waiting for
---------------------------------------------------------
set pages 50000 lines 32767
col EVENT for a40

select a.sid, a.serial#, a.status, a.program, b.event,to_char(a.logon_time, 'dd-mon-yy hh24:mi') LOGON_TIME,to_char(Sysdate, 'dd-mon-yy-hh24:mi') CURRENT_TIME, (a.last_call_et/3600) "Hrs connected" from v$session a,v$session_wait b where a.sid in(&SIDs) and a.sid=b.sid order by 8;

--Session details associated with Oracle SID
-------------------------------------------
set head off
set verify off
set echo off
set pages 1500
set linesize 100
set lines 120
prompt
prompt Details of SID / SPID / Client PID
prompt ==================================
select /*+ CHOOSE*/
'Session  Id.............................................: '||s.sid,
'Serial Num..............................................: '||s.serial#,
'User Name ..............................................: '||s.username,
'Session Status .........................................: '||s.status,
'Client Process Id on Client Machine ....................: '||'*'||s.process||'*'  Client,
'Server Process ID ......................................: '||p.spid Server,
'Sql_Address ............................................: '||s.sql_address,
'Sql_hash_value .........................................: '||s.sql_hash_value,
'Schema Name ..... ......................................: '||s.SCHEMANAME,
'Program  ...............................................: '||s.program,
'Module .................................................: '|| s.module,
'Action .................................................: '||s.action,
'Terminal ...............................................: '||s.terminal,
'Client Machine .........................................: '||s.machine,
'LAST_CALL_ET ...........................................: '||s.last_call_et,
'S.LAST_CALL_ET/3600 ....................................: '||s.last_call_et/3600
from v$session s, v$process p
where p.addr=s.paddr and
s.sid=nvl('&sid',s.sid) 
/
set head on

--Checking for Active Transactions SID
------------------------------------
select username,t.used_ublk,t.used_urec from v$transaction t,v$session s where t.addr=s.taddr;

--Session details from Session longops
-------------------------------------
select inst_id,SID,SERIAL#,OPNAME,SOFAR,TOTALWORK,START_TIME,LAST_UPDATE_TIME, username from gv$session_longops;


--Session details with SPID
-------------------------
select sid, serial#, USERNAME, STATUS, OSUSER, PROCESS,
MACHINE, MODULE, ACTION, to_char(LOGON_TIME,'yyyy-mm-dd hh24:mi:ss')
from v$session where paddr in (select addr from v$process where spid = '&spid')
/ 

--To find Undo Generated For a given session
------------------------------------------
select  username,
t.used_ublk ,t.used_urec
from    gv$transaction t,gv$session s
where   t.addr=s.taddr and
s.sid='&sid';

--To list count of connections from other machines
------------------------------------------------
select count(1),machine from gv$session where inst_id='&inst_id' group by machine;

--To get total count of sessions and processes
--------------------------------------------
select count(*) from v$session;

select count(*) from v$process;

select (select count(*) from v$session) sessions, (select count(*) from v$process) processes from dual;

--To find sqltext thru sqladdress
-------------------------------
select sql_address from v$session where sid=1999;

select sql_text from v$sqltext where ADDRESS='C00000027FF00AF0' order by PIECE;

--To find sqltext for different sql hashvalue
-------------------------------------------
select hash_value,sql_text from v$sql where hash_value in (1937378691,1564286875,
248741712,2235840973,2787402785)

--To list long running forms user sessions
----------------------------------------
select s.sid,s.process,p.spid,s.status ,s.action,s.module, (s.last_call_et/3600) from
v$session s, v$process p where round(last_call_et/3600) >4 and action like '%FRM%' and
p.addr=s.paddr ;

--To list inactive Sessions respective username
---------------------------------------------
SELECT username,count(*) num_inv_sess
FROM v$session
where last_call_et > 3600
and username is not null
AND STATUS='INACTIVE'
group by username
order by num_inv_sess DESC;

SELECT count(*) FROM v$session where last_call_et > 43200 and username is not null AND
STATUS='INACTIVE';
SELECT count(*) FROM v$session where last_call_et > 3600 and username is not null AND
STATUS='INACTIVE';

--To find session id with set of SPIDs
------------------------------------
select sid from v$session, v$process where addr=paddr and spid in ('11555','26265','11533');

--To find Sql Text given SQLHASH & SQLADDR
----------------------------------------
select piece,sql_text from v$sqltext where HASH_VALUE = &hash and ADDRESS ='&addr' order by piece;
select piece,sql_text from v$sqltext where  ADDRESS ='&addr' order by piece;
