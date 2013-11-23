--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: obj_infoid.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays information for given object_id
--
prompt Parameter 1: Object-Id from dba_objects

column object_name format a30
column object_type format a20
column owner format a20
column last_ddl format a17
column created format a17
column status format a10

set lines 120
set pages 200
select owner
      ,object_name
      ,object_type
      ,status 
      ,to_char(last_ddl_time,'dd.mm.yy hh24:mi:SS') last_ddl
      ,to_char(created,'dd.mm.yy hh24:mi:SS') created
  from dba_objects
 where object_id =&1
;

