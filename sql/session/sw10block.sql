--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sw10block.sql 363 2011-10-17 05:17:25Z tbr $
--
-- Display blocking sessions from v$session
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
column sm format a2

select vs.status status
     , vs.sid sid
     , vs.serial# serial
     , case vs.server when 'SHARED' THEN 'S' when 'DEDICATED' THEN 'D' else 'u' end sm
     , vs.machine
     , vs.osuser
     , vs.username
     , sw.seconds_in_wait sw
     , vs.BLOCKING_SESSION_STATUS BSS
     , vs.BLOCKING_SESSION BSSID
     , sw.event,
sw.state
  from v$session_wait sw, v$session vs
where type != 'BACKGROUND'
  and vs.sid=sw.sid
  and vs.status not in ('INACTIVE','KILLED')
order by 1 desc
;
