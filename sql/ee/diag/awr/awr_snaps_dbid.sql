-- Parameter 1: DB-ID
--
-- List of AWR-Snapshots for DBID
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awr_snaps_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--
set pagesize 100
set lines 120
set verify off

column snap_id format 99999999
column instance_number format 99
column endezeit format a18
select a.snap_id, a.instance_number, to_char(a.end_interval_time,'dd.mm.yy hh24:mi:ss') endezeit
from DBA_HIST_SNAPSHOT a
where dbid = &1
order by snap_id
;

