--CDB Container - CDBFSCM (login into this container as sysdba and then switch to PDB Container)

--PDB Container - EP92U021

SET ORACLE_SID=CDBFSCM (Windows) (open cmd from local m/c)

OR

export ORACLE_SID=CDBFSCM (Linux) (log into your VM)

sqlplus "/ as sysdba"

SHOW CON_NAME;

SELECT USERNAME FROM DBA_USERS;

ALTER SESSION SET CONTAINER = EP92U021;

SELECT USERNAME FROM DBA_USERS;

GRANT SELECT_CATALOG_ROLE to SYSADM;

GRANT DBA to SYSADM;

GRANT ALL PRIVILEGES TO SYSADM;

GRANT ALL ON v_$session to SYSADM;

GRANT ALL ON v_$sql to SYSADM;

GRANT ALL ON v_$session_longops to SYSADM;

COMMIT;
