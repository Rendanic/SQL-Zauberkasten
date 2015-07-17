--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 17.07.2015
--
-- Display waiting PQ sessions in Queue
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
     , vs.CURRENT_QUEUE_DURATION sw
	 , sw.event,
sw.state
  from v$session_wait sw, v$session vs
where type != 'BACKGROUND'
  and vs.pq_status='ENABLED' and vs.CURRENT_QUEUE_DURATION > 0
  and vs.sid=sw.sid
order by vs.CURRENT_QUEUE_DURATION , status desc
;
