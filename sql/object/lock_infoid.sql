--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- List all Sessions with Locks on given object Id
--
-- Use obj_info to get the object_id for this script.
--
-- Date 08.05.2017
-- Version 1
--
-- Parameter 1. Object-Id

set lines 120 pages 100
column owner format a30
column OBJECT_NAME format a30
column STATUS format a10
column SID format 9999
column SERIAL# format 99999

select
   c.owner,
   c.object_name,
   b.sid,
   b.serial#,
   b.status
from
   gv$locked_object a
   join gv$session b on b.sid = a.session_id and a.inst_id = b.inst_id
   join dba_objects c on a.object_id = c.object_id
where c.OBJECT_ID = &1
;
