--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spool_privs4user_non_sys.sql 465 2012-09-06 11:19:11Z tbr $
--
-- spool 'grant user ...' for all non sys-users
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
                                      ,' on ' )
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
where grantee not in ('ANONYMOUS','CTXSYS','DBSNMP','DIP','DMSYS','DM_CATALOG_ROLE'
                     ,'EXFSYS','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','ORACLE_OCM'
					 ,'ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','SI_INFORMTN_SCHEMA'
					 ,'SYS','SYSMAN','SYSTEM','TSMSYS','WMSYS'
					 ,'XS$NULL','XDB'
					 ,'AQ_ADMINISTRATOR_ROLE',
					 'AQ_USER_ROLE',
					 'AUTHENTICATEDUSER',
					 'CONNECT',
					 'CTXAPP',
					 'DBA',
					 'DELETE_CATALOG_ROLE',
					 'EJBCLIENT',
					 'EXECUTE_CATALOG_ROLE',
					 'EXP_FULL_DATABASE',
					 'GATHER_SYSTEM_STATISTICS',
					 'HS_ADMIN_ROLE',
					 'IMP_FULL_DATABASE',
					 'JAVADEBUGPRIV',
					 'JAVAIDPRIV',
					 'JAVASYSPRIV',
					 'JAVAUSERPRIV',
					 'JAVA_ADMIN',
					 'JAVA_DEPLOY',
					 'LBAC_DBA',
					 'LOGSTDBY_ADMINISTRATOR',
					 'MGMT_USER',
					 'OEM_ADVISOR',
					 'OEM_MONITOR',
					 'OLAP_DBA',
					 'OLAPSYS',
					 'OLAP_USER',
					 'RECOVERY_CATALOG_OWNER',
					 'RESOURCE',
					 'SCHEDULER_ADMIN',
					 'SELECT_CATALOG_ROLE',
					 'WKPROXY',
					 'WK_TEST',
					  'WK_USER',					 
					 'WKSYS', 
					 'WMSYS',
					 'WM_ADMIN_ROLE',
					 'XDBADMIN',
					 'XDBWEBSERVICES',
					 'PUBLIC'
					 )
order by grantee,3,2,4
)
)
;
