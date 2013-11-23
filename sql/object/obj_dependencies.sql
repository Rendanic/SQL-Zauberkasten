--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: obj_dependencies.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays dependencies for given object
--
prompt Parameter 1: Owner
prompt Parameter 2: Object-Name


column owner format a20
column name format a30
column REFERENCED_OWNER format a20
column REFERENCED_NAME format a30
column REFERENCED_TYPE format a17

set lines 140
set pages 100
set verify off

select 
      owner
      ,name
      ,REFERENCED_OWNER
      ,REFERENCED_NAME
      ,REFERENCED_TYPE
  from dba_dependencies
 where owner like '&1'
   and name like '&2'
order by 1,2,3,4,5
;

