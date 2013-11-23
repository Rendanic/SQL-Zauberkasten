--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sqlactive2.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Display active cursors for given SessionID
--
-- Parameter 1: Oracle SessionID
--
set echo off
set lines 120

column sql_id format a13 
column buffer_gets format 99999999999
column DISK_READS format 99999999999
column cput_ms format 999999999
column sql_text format a40
column VSC format 999
select sql_id
     , child_number cn
     , version_count vc
     , buffer_gets
     , DISK_READS
     , round(cpu_time/1000) cput_ms
     , to_char(LAST_ACTIVE_TIME, 'DD.MM HH24:MI:SS') lasttime
     , sql_text
from (
select voc.sql_id, vs.version_count
     , vsp.CHILD_NUMBER
     , vs.buffer_gets, vs.DISK_READS, vs.cpu_time
      ,vs.LAST_ACTIVE_TIME, voc.sql_text sql_text
from GV$sqlarea voc
join V$SQLAREA_PLAN_HASH vs on vs.sql_id = voc.sql_id
join v$sql_plan vsp on vsp.sql_id = vs.sql_id
where voc.sql_id='&1'
order by last_active_time desc
)
where rownum < 50
order by last_active_time
;

