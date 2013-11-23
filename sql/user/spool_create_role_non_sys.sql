--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spool_create_role_non_sys.sql 461 2012-09-05 14:14:45Z tbr $
--
-- spool 'create role identified by ..' for all non sys-users
--

set lines 500 trimspool on pages 1000 verify off
select 'create role ' || role
	   ||';' create_role
from dba_roles
where role not in('ANONYMOUS','CTXSYS','DBSNMP','DIP','DMSYS'
                     ,'EXFSYS','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','ORACLE_OCM'
					 ,'ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','SI_INFORMTN_SCHEMA'
					 ,'SYS','SYSMAN','SYSTEM','TSMSYS','WMSYS'
					 ,'XS$NULL','XDB'
					 ,'AQ_ADMINISTRATOR_ROLE',
					 'ADM_PARALLEL_EXECUTE_TASK',
					 'AQ_USER_ROLE',
					 'APEX_ADMINISTRATOR_ROLE',
					 'DATAPUMP_EXP_FULL_DATABASE',
					 'DATAPUMP_IMP_FULL_DATABASE',
					 'DBFS_ROLE',
					 'HS_ADMIN_EXECUTE_ROLE',
					 'HS_ADMIN_SELECT_ROLE',
					 'JMXSERVER',
					 'CSW_USR_ROLE',
					 'CWM_USER',
					 'OLAP_XS_ADMIN',
					 'ORDADMIN',
					 'OWB$CLIENT',
					 'OWB_DESIGNCENTER_VIEW',
					 'OWB_USER',
					 'SPATIAL_CSW_ADMIN',
					 'SPATIAL_WFS_ADMIN',
					 'WFS_USR_ROLE',
					 'XDB_SET_INVOKER',
					 'XDB_SET_INVOKER',
					 'XDB_WEBSERVICES',
					 'XDB_WEBSERVICES_OVER_HTTP',
					 'XDB_WEBSERVICES_WITH_PUBLIC',
					 'AUTHENTICATEDUSER',
					 'CONNECT',
					 'CTXAPP',
					 'DBA',
					 'DELETE_CATALOG_ROLE',
					 'EJBCLIENT',
					 'EXECUTE_CATALOG_ROLE',
					 'EXP_FULL_DATABASE',
					 'GATHER_SYSTEM_STATISTICS',
					 'GLOBAL_AQ_USER_ROLE',
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
					 'OLAP_USER',
					 'RECOVERY_CATALOG_OWNER',
					 'RESOURCE',
					 'SCHEDULER_ADMIN',
					 'SELECT_CATALOG_ROLE',
					 'WKUSER',
					 'WM_ADMIN_ROLE',
					 'XDBADMIN',
					 'XDBWEBSERVICES',
					 'PUBLIC'
					 )
order by role;
