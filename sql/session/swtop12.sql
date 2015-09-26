--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date: 26.09.2015
--
-- display all Sessions from v$session ordered by seconds in wait
--
-- This is a special version for Oracle 12c+ with pdb-informations
--
set linesize 200
set heading on
set pagesize 1000
column status tru format a5
column state format a10
column event format a20
column PDB_NAME format a20
column sw format 99999
column osuser format a15
column username format a10
column machine format a15

select vs.status status
     , vs.sid sid
	 , decode(vs.con_id, 1, 'CDB$ROOT', p.name) PDB_NAME
     , vs.machine
	 , vs.osuser
	 , vs.username
     , sw.seconds_in_wait sw
	 , sw.event,
sw.state
  from v$session_wait sw, v$session vs, v$pdbs p
where type != 'BACKGROUND'
  and vs.sid=sw.sid
  and vs.con_id = p.con_id(+)
order by sw.seconds_in_wait desc, status desc
;
