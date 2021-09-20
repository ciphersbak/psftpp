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

