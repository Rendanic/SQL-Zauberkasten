--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spool_create_user_non_sys.sql 462 2012-09-05 14:17:51Z tbr $
--
-- spool 'create user identified by ..' for all non sys-users
--

set lines 500 trimspool on pages 1000 verify off
select 'create user ' || username || ' identified by values '''||password||''''
       ||' default tablespace ' || default_tablespace || ' temporary tablespace '
	   ||TEMPORARY_TABLESPACE
	   ||' PROFILE ' ||PROFILE
	   ||' account ' || decode(ACCOUNT_STATUS,'OPEN', 'UNLOCK','LOCK')
	   ||';' create_user
from dba_users
where username not in('ANONYMOUS','CTXSYS','DBSNMP','DIP','DMSYS'
                     ,'EXFSYS','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','ORACLE_OCM'
					 ,'OLAPSYS'
					 ,'ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','SI_INFORMTN_SCHEMA'
					 ,'SYS','SYSMAN','SYSTEM','TSMSYS','WKPROXY','WK_TEST', 'WMSYS'
					 ,'XS$NULL','XDB'
					 ,'APEX_030200','APEX_PUBLIC_USER','APPQOSSYS','FLOWS_FILES'
					 ,'ORDDATA','OWBSYS','OWBSYS_AUDIT','SCOTT','SPATIAL_CSW_ADMIN_USR'
					 ,'SPATIAL_WFS_ADMIN_USR')
order by username;

select 'alter user ' || username 
       || ' quota '||decode(MAX_BYTES,-1,'unlimited',MAX_BYTES)
	   || ' on '||TABLESPACE_NAME
	   ||';' create_user
from dba_ts_quotas
where username not in('ANONYMOUS','CTXSYS','DBSNMP','DIP','DMSYS'
                     ,'EXFSYS','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','ORACLE_OCM'
					 ,'OLAPSYS'
					 ,'ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','SI_INFORMTN_SCHEMA'
					 ,'SYS','SYSMAN','SYSTEM','TSMSYS','WKPROXY','WK_TEST', 'WMSYS'
					 ,'XS$NULL','XDB'
					 ,'APEX_030200','APEX_PUBLIC_USER','APPQOSSYS','FLOWS_FILES'
					 ,'ORDDATA','OWBSYS','OWBSYS_AUDIT','SCOTT','SPATIAL_CSW_ADMIN_USR'
					 ,'SPATIAL_WFS_ADMIN_USR')
order by username,TABLESPACE_NAME;
