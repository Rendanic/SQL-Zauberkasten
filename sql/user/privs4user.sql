--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: privs4user.sql 30 2010-01-12 20:58:11Z oracle $
--
-- all priviledges for a user
--
-- Parameter 1: Username or role
--
--prompt SET MARKUP HTML ON ENTMAP on spool on
set pagesize 10000
set lines 100

column grantee format a30
column role_recht format a30
column object_name format a30

select grantee, granted_role role_recht ,object_name
from
(
select *
from 
(
 select grantee, granted_role,'1', ' ' object_name
 from dba_role_privs
 union all
 select grantee, privilege,'2',' ' 
 from dba_sys_privs
 union all
 select grantee, privilege, '3',owner||'.'||table_name
 from dba_tab_privs
)
where grantee like '&1'
order by grantee,3,2,4
)
;
