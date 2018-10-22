--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 22.10.2018
--
-- Diesplay some basic information from the data dictionary
-- Oracle 12c or newer required!
--

set echo off
column name format a8
column flashb format a6
column db_role format a10
column created format a14
column RESETLOGS_TIME format a14
column open_mode format a12
column db_role format a18
column lmode format a6
set feedback off
set lines 120

select dbid, name
      ,to_char(created, 'dd.mm.yy HH24:mi') created
      ,to_char(RESETLOGS_TIME, 'dd.mm.yy HH24:mi') RESETLOGS_TIME
      ,OPEN_MODE
      ,DATABASE_ROLE db_role
      ,log_mode
      ,FLASHBACK_ON flashb
  from v$database;

column force_logging format a13
column NLS_CHARACTERSET format a16
column NLS_NCHAR_CHARACTERSET format a22
column local_undo format a10

select vd.force_logging
      ,nls1.value NLS_CHARACTERSET
      ,nls2.value NLS_NCHAR_CHARACTERSET
      ,nvl(lu.property_value, 'unknown') local_undo
from v$database vd
join nls_database_parameters nls1 on nls1.parameter = 'NLS_CHARACTERSET'
join nls_database_parameters nls2 on nls2.parameter = 'NLS_NCHAR_CHARACTERSET'
left outer join database_properties lu on lu.property_name = 'LOCAL_UNDO_ENABLED';

column Block_change_tracking format a21
select status Block_change_tracking
from V$BLOCK_CHANGE_TRACKING;

@@vpdb.sql

@@vi
@@redothread

set feedback off

@@dba_registry
set feedback off
@@registry

set lines 145 pages 100

column PATCH_ID format 99999999
column PATCH_UID format 99999999
column DESCRIPTION format a80
column status format a10 
column VERSION format a12
column applied format a9
column bundle format a5

PROMPT sqlpatch information

select PATCH_ID
     , PATCH_UID
     , VERSION
     , STATUS 
     , BUNDLE_SERIES bundle
     , substr(ACTION_TIME,1,9) applied
     , DESCRIPTION
from  dba_registry_sqlpatch
order by action_time
;

prompt
PROMPT CPU-Statistik
@@dba_cpu_usage_stat
@@hist_database_instance

set feedback on
