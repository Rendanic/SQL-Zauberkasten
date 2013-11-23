-- Parameter 1: DB-ID
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spsnap_dbid.sql 57 2010-03-13 10:00:31Z tbr $
--
-- Display Snapshots for given dbid
--

set lines 120 pages 30 echo off verify off

column inst_id format 99
column start_time format a17
column snapshot_time format a17
column Start_SNAP_ID format 999999
column sl format 99
column b format a1

select INSTANCE_NUMBER inst_id
      ,SNAP_ID Start_SNAP_ID
      ,to_char(SNAP_TIME,'dd.mm.yy hh24:mi:ss') snapshot_time
      ,snap_level sl
      ,baseline b
      ,to_char(STARTUP_TIME,'dd.mm.yy hh24:mi:ss') start_time
from stats$snapshot
where dbid=&1
order by snap_time,instance_number;
