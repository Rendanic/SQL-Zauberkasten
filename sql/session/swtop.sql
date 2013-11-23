--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: swtop.sql 233 2010-11-13 20:42:23Z tbr $
--
-- display all Sessions from v$session ordered by seconds in wait
--
set linesize 200
set heading on
set pagesize 1000
column status tru format a5
column state format a10
column event format a20
column sid format 99999
column sw format 99999
column osuser format a15
column username format a10
column machine format a15

select vs.status status
     , vs.sid sid
	 , vs.serial# serial
     , vs.machine
	 , vs.osuser
	 , vs.username
     , sw.seconds_in_wait sw
	 , sw.event,
sw.state
  from v$session_wait sw, v$session vs
where type != 'BACKGROUND'
  and vs.sid=sw.sid
order by sw.seconds_in_wait desc, status desc
;
