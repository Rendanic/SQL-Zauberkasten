--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 20.03.2015
--
--  Sessions for a connected user from v$session
--
-- Parameter 1: DB_USERNAME

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
  and username like '&1'
order by sw.seconds_in_wait desc, status desc
;
