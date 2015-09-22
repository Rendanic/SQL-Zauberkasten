--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 22.09.2015
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
column CDB format a3
column PLATFORM_NAME format a30
select force_logging, CDB, PLATFORM_NAME
from v$database;

column Block_change_tracking format a30
select status Block_change_tracking
from V$BLOCK_CHANGE_TRACKING;


@@vi
@@redothread

set feedback off

@@dba_registry
set feedback off
@@registry

prompt
PROMPT CPU-Statistik
@@dba_cpu_usage_stat
@@hist_database_instance

set feedback on
