--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dbms_metadata_user.sql 776 2013-04-04 14:28:11Z tbr $
--
-- prints DDL for create user with all grants
--

-- 1. Parameter : OBJECT_NAME

set long 10000000
set longchunksize 10000000
set lines 2000
set pages 0
set trimspool on
set heading off

begin
   DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
end;
/


set feedback off verify off

SELECT DBMS_METADATA.GET_DDL('USER', '&1') text
from dual;

SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', '&1') text
from dual
where exists (select 1 from dba_sys_privs where grantee = '&1' and rownum = 1);

SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', '&1') text
FROM dual
where exists (select 1 from dba_role_privs where grantee = '&1' and rownum = 1);


SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', '&1') text
FROM dual
where exists (select 1 from dba_tab_privs where grantee = '&1' and rownum = 1);

set heading on

