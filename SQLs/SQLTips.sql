--Get the host name
select sys_context('USERENV', 'SERVER_HOST')
from dual;

--info command
info+ PSPRCSRQST;
/

select /*insert*/ * from PSXLATITEM WHERE FIELDNAME = 'PMT_STATUS';

REM INSERTING into PSXLATITEM
SET DEFINE OFF;
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','C',to_date('01-JAN-00','DD-MON-RR'),'A','Canceled','Canceled',to_timestamp('24-AUG-04 05.16.17.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30568);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','E',to_date('01-JAN-00','DD-MON-RR'),'A','Error','Error',to_timestamp('20-APR-04 05.53.25.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30569);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','H',to_date('01-JAN-00','DD-MON-RR'),'A','Flagged for Hold','Hold',to_timestamp('04-MAY-04 05.04.00.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30570);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','L',to_date('01-JAN-00','DD-MON-RR'),'A','Awaiting Dispatch','Awaiting',to_timestamp('05-OCT-04 05.38.23.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30572);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','P',to_date('01-JAN-00','DD-MON-RR'),'A','Paid','Paid',to_timestamp('20-APR-04 05.53.25.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30573);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','R',to_date('01-JAN-00','DD-MON-RR'),'A','Received by Bank','Received',to_timestamp('20-APR-04 05.53.25.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30574);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','S',to_date('01-JAN-00','DD-MON-RR'),'A','Dispatched to Bank','Dispatched',to_timestamp('01-FEB-05 05.07.41.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',30575);
Insert into PSXLATITEM (FIELDNAME,FIELDVALUE,EFFDT,EFF_STATUS,XLATLONGNAME,XLATSHORTNAME,LASTUPDDTTM,LASTUPDOPRID,SYNCID) values ('PMT_STATUS','SC',to_date('01-JAN-00','DD-MON-RR'),'A','In Process','In Process',to_timestamp('04-MAY-04 05.04.00.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),'PPLSOFT',31233);

8 rows selected. 

--https://connor-mcdonald.com/2019/05/17/hacking-together-faster-inserts/
--multi-table insert

select s.name, st.value
from v$statname s, v$mystat st
where st.statistic# = s.statistic#
and s.name like '%- undo records applied';

select count(*), count(distinct(dbms_rowid.rowid_block_number(rowid))) blks
from PSXLATITEM;

SELECT count(*) from dba_recyclebin;

desc user_tab_partitions;
select * from user_tab_partitions;

with
  function par_high_value(p_tname varchar2, p_parname varchar2)
  return varchar2 is
    l_high_value varchar2(4000);
  begin
    select high_value
    into l_high_value
    from user_tab_partitions
    where table_name = p_tname
    and partition_name = p_parname;
    
    return l_high_value;
  end;
select 
  table_name,
  partition_name,
  par_high_value(table_name, partition_name) high_value
from user_tab_partitions t
where table_name in ('T', 'T1');

select table_name, num_rows, blocks, avg_row_len
from all_tables
where table_name LIKE ('PS%');


--Hints
select /*+ leading(e) use_hash(d) */ *
from scott.emp e,
     scott.dept d
where e.deptno = d.deptno
and   d.dname = 'SALES';

--To handle query transformations (by the DB), ordered hints can be ignored.
--Hence, when you have an inline view and would like the optimiser to use the ordered hint, use as follows

select /*+ no_merge(inline view alias) ordered */ * from dual;

--Lag/Lead
--https://www.youtube.com/watch?v=wezjYiBvKwc
--lag(status) over (partition by order_id order by status_date) lag_status
--lead(status) over (partition by order_id order by status_date) lead_status

--Buffer Gets
--https://www.youtube.com/watch?v=z-4K9ncd0IU&list=PLJMaoEWvHwFIW2CUsD_qIi7v-etjhZJPo&index=5
select sql_text, buffer_gets, executions
from v$sqlstats
where buffer_gets > 100000
order by 2;
/

select xmltype(other_xml) from v$sql_plan
where other_xml is not null
and sql_id = '3qyuxjtjy92m5'
and child_number > 0;
/

--rowid
select dump(rowid) from PS_CASH_FLOW_TR WHERE TR_SOURCE_CD IN ('D', 'X') AND SOURCE_BUS_UNIT = 'UNDP1' AND TR_SOURCE_ID IN ('DL00105210', 'BT00085232') AND AMOUNT < 0;
/

--Break down a HEX string
--count the total characters and then divide by 2. That drives the last connect by level clause
with str as
(select '787903120E12311B2E0200' x from dual)
select substr(x, level*2-1,2) hexstr
from str
connect by level <=11;

--convert to decimal
with str as
(select '787903120E12311B2E0200' x from dual)
select to_number(substr(x, level*2-1,2), 'XX') DEC
from str
connect by level <= 7;

--get the nanoseconds
with str as
(select '787903120E12311B2E0200' x from dual)
select to_number(substr(x,15,8), 'XXXXXXXX') DEC
from str;

set autotrace traceonly stat
select * from ps_BNK_CURR_RVL_VW where SETID = 'SHARE' AND BANK_CD = '00328' ORDER BY EFFDT DESC;
/

--https://carlos-sierra.net/2013/09/12/function-to-compute-sql_id-out-of-sql_text/
--https://www.perumal.org/computing-oracle-sql_id-and-hash_value/
--https://www.youtube.com/watch?v=cJsNlcqh6_4

SELECT /* RAM_VSQL */
      'SQL_TEXT                     : ' || v.sql_text                                               || CHR(10) ||
      'SQL_ID                       : ' || v.sql_id                                                 || CHR(10) ||
      'HASH_VALUE                   : ' || v.hash_value                                             || CHR(10) ||
      'HASH_VALUE_HEX               : ' || TO_CHAR (v.hash_value, 'FMXXXXXXXX')                     || CHR(10) ||
      'EXACT_MATCHING_SIGNATURE     : ' || v.exact_matching_signature                               || CHR(10) ||
      'EXACT_MATCHING_SIGNATURE_HEX : ' || TO_CHAR (exact_matching_signature, 'FMXXXXXXXXXXXXXXXX') || CHR(10) ||
      'FORCE_MATCHING_SIGNATURE     : ' || v.force_matching_signature                               || CHR(10) ||
      'FORCE_MATCHING_SIGNATURE_HEX : ' || TO_CHAR (force_matching_signature, 'FMXXXXXXXXXXXXXXXX') || CHR(10) AS stmt_information
  FROM v$sql v
 WHERE v.sql_text LIKE '%PS_PYMNT_VCHR_XREF where business_unit = ''SOM10'' and voucher_id = ''00159716''' AND v.sql_text NOT LIKE '%RAM_VSQL%';
