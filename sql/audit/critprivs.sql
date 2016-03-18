--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
--
-- Version: 1
-- Date: 18.03.2016
--
-- Display critical priviledges for Users
--
-- Parameter 1: Username with like ''

set pagesize 10000
set lines 100
set verify off

column grantee format a30
column role_recht format a30
column object_name format a30

select grantee, privilege
from
(
select *
from 
(
 select grantee, privilege
 from dba_sys_privs
)
where grantee like '&1'
  and grantee not in ('SYS', 'SYSTEM'
                     ,'APEX_040200'
                     ,'AQ_ADMINISTRATOR_ROLE'
                     ,'CTXSYS'
                     ,'DBSNMP'
                     ,'AUDIT_ADMIN'
                     ,'DATAPUMP_IMP_FULL_DATABASE'
                     ,'DV_REALM_OWNER'
                     ,'DVSYS'
                     ,'DV_ACCTMGR'
                     ,'DV_OWNER'
                     ,'DV_OWNER'
                     ,'EXP_FULL_DATABASE'
                     ,'WMSYS'
                     ,'EM_EXPRESS_ALL'
                     ,'DBA'
                     ,'GSMADMIN_INTERNAL'
                     ,'GSMADMIN_ROLE'
                     ,'IMP_FULL_DATABASE'
                     ,'JAVADEBUGPRIV'
                     ,'LBACSYS'
                     ,'MDSYS'
                     ,'OEM_ADVISOR'
                     ,'OEM_MONITOR'
                     ,'OLAP_DBA'
                     ,'ORACLE_OCM'
                     ,'ORDPLUGINS'
                     ,'ORDSYS'
                     ,'OUTLN'
                     ,'PERFSTAT'
                     ,'RECOVERY_CATALOG_OWNER'
                     ,'SCHEDULER_ADMIN'
                     ,'SPATIAL_WFS_ADMIN_USR'
                     ,'SPATIAL_CSW_ADMIN_USR'
                     ,'SYSBACKUP'
                     ,'SYSDG'
                     ,'XDB'
)
  and (privilege IN('ADMINISTER DATABASE TRIGGER'
                 ,'ADMINISTER SQL MANAGMENT OBJECT'
                 ,'ADMINISTER SQL TUNING SET'
                 ,'ADVISOR'
                 ,'ALTER DATABASE'
                 ,'ALTER PROFILE'
                 ,'ALTER RESOURCE COST'
                 ,'ALTER ROLLBACK SEGMENT'
                 ,'ALTER SYSTEM'
                 ,'ALTER TABLESPACE'
                 ,'ALTER USER'
                 ,'AUDIT SYSTEM'
                 ,'BECOME USER'
                 ,'CREATE CONTROLFILE'
                 ,'CREATE DIRECTORY'
                 ,'CREATE LIBRARY'
                 ,'CREATE PROFILE'
                 ,'CREATE PUBLIC SYNONYM'
                 ,'CREATE ROLLBACK SEGMENT'
                 ,'CREATE TABLESPACE'
                 ,'CREATE USER'
                 ,'DROP PROFILE'
                 ,'DROP PUBLIC DATABASE LINK'
                 ,'DROP PUBLIC SYNONYM'
                 ,'DROP ROLLBACK SEGMENT'
                 ,'DROP TABLESPACE'
                 ,'DROP USER'
                 ,'EXPORT FULL DATABASE'
                 ,'FLASHBACK ARCHIVE ADMINISTER'
                 ,'GLOBAL QUERY REWRITE'
                 ,'GRANT ANY ROLE'
                 ,'GRANT ANY PRIVILEGE'
                 ,'GRANT OBJECT PRIVILEGE'
                 ,'IMPORT FULL DATABASE'
                 ,'MANAGE FILE GROUP'
                 ,'MANAGE SCHEDULER'
                 ,'MANAGE TABLESPACE'
                 ,'RESTRICTED SESSION'
                 ,'SYSDBA'
                 ,'SYSOPER'
                 )    
or
  privilege like '% ANY %')
order by 1,2
)
;
