begin
    for c1 in (select owner,table_name from dba_tables where table_name LIKE 'PS_PC_PDJ_CP_TA0%') loop
        execute immediate 'drop table '||c1.owner||'.'||c1.table_name||'';
    end loop;
end;
--PS_PC_PDJ_CP_TA0
begin
    for c1 in (select table_name from user_tables where table_name LIKE 'PS_PC_PDJ_CP_TA0%') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;

--PS_PC_PO_TAO1
begin
    for c1 in (select table_name from user_tables where table_name LIKE 'PS_PC_PO_TAO1%') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;

--PS_PC_PRJA_TA0
begin
    for c1 in (select table_name from user_tables where table_name LIKE 'PS_PC_PRJA_TA0%') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;

--PS_PC_REQ_TAO1
begin
    for c1 in (select table_name from user_tables where table_name LIKE 'PS_PC_REQ_TAO1%') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;

--PS_PC_RES_PA_TA9
begin
    for c1 in (select table_name from user_tables where table_name LIKE 'PS_PC_RES_PA_TA9%') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;
