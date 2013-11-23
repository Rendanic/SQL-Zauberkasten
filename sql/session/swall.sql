--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: swall.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Dispay all sessions from v$session
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
	 , sw.event
	 , sw.state
  from v$session_wait sw, v$session vs
where 1=1
  and vs.sid=sw.sid
order by 1 desc
;
