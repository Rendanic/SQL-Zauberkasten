--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: vd.sql 22 2010-03-10 04:34:49Z tbr $
--
set echo off
column name format a8

select dbid, name
      ,to_char(created, 'dd.mm.yy HH24:mi') created
      ,to_char(RESETLOGS_TIME, 'dd.mm.yy HH24:mi') RESETLOGS_TIME
      ,OPEN_MODE
      ,DATABASE_ROLE
      ,LOG_MODE
  from v$database;

@@vi
@@dba_registry
