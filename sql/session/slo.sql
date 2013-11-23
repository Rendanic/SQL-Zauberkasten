--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: slo.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Session Long Operations
--
set pages 1000
set lines 110
column rt format 999999
column message format a90

select *
  from(
  select sid, time_remaining rt, message
  from v$session_longops
  where time_remaining > 0
  order by last_update_time desc
  )
  where rownum < 20
order by sid

/
