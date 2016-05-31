--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Displays information from dba_objects
--
-- Date: 31.05.2016

-- Parameter 1: Object-Owner
-- Parameter 2: Object-Name

column object_name format a30
column object_type format a20
column owner format a20
column status format a10
column last_ddl format a17
column created format a17

set lines 130
set pages 200
set verify off

select object_id
      ,owner
      ,object_name
      ,object_type
      ,status
      ,to_char(last_ddl_time,'dd.mm.yy hh24:mi:SS') last_ddl
      ,to_char(created,'dd.mm.yy hh24:mi:SS') created
  from dba_objects
 where owner like '&1'
   and object_name like '&2'
order by object_name, object_type
;
