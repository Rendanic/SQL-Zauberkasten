--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: privs4user_spool.sql 30 2010-01-12 20:58:11Z oracle $
--
-- all priviledges for a user in spool format
--
-- Parameter 1: Username or role
--
--prompt SET MARKUP HTML ON ENTMAP on spool on
set pagesize 10000
set lines 100

column grantee format a30
column role_recht format a30
column object_name format a30

select 'grant "'|| role_recht || decode(tview
                                      ,'1'     ,'" '
                                      ,'2'     ,'" '
                                      ,'" on "' )
       || object_name || ' to "'|| grantee||'";'
from(
select grantee, granted_role role_recht ,object_name, tview
from
(
select *
from 
(
 select grantee, granted_role,'1' tview, ' ' object_name
 from dba_role_privs
 union all
 select grantee, privilege,'2' tview,' ' 
 from dba_sys_privs
 union all
 select grantee, privilege, '3' tview,owner||'.'||table_name
 from dba_tab_privs
)
where grantee like '&1'
order by grantee,3,2,4
)
)
;
