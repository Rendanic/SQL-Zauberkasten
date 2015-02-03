--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spool_public_synonym_non_sys.sql 463 2012-09-05 14:20:22Z tbr $
--
-- spool 'create public synonym ...' for all non sys-users
--
--prompt SET MARKUP HTML ON ENTMAP on spool on
set pagesize 10000
set lines 100
set head off

select 'create public synonym "'|| synonym_name||'"'
       ||' for "' || TABLE_OWNER||'"."'||TABLE_NAME||'"'
	   ||nvl2(DB_LINK,'@'||DB_LINK,null)
	   ||';' as script
from dba_synonyms
where owner = 'PUBLIC'
  and table_owner not in ('ANONYMOUS','CTXSYS','DBSNMP','DIP','DMSYS'
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
					 'APEX_030200',
					 'APEX_040100',
					 'DELETE_CATALOG_ROLE',
					 'EJBCLIENT',
					 'ORDDATA',
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
					 'OLAPSYS',
					 'RECOVERY_CATALOG_OWNER',
					 'RESOURCE',
					 'SCHEDULER_ADMIN',
					 'SELECT_CATALOG_ROLE',
					 'WKPROXY',
					 'WK_TEST', 
					 'WMSYS',
					 'WM_ADMIN_ROLE',
					 'XDBADMIN',
					 'XDBWEBSERVICES',
					 'PUBLIC',
					 'APPQOSSYS',
					 'FLOWS_FILES'
					 )
order by 1
;
