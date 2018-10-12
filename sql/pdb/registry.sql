--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date: 12.10.2018
--
-- Information for changes in dba_registry_history
--
set pages 100
set lines 120

column name format a20
column COMP_NAME format a45
column COMP_ID format a10
column STATUS format a10
column VERSION format a12

alter session set "_exclude_seed_cdb_view"=false;

select c.name
      ,r.COMP_NAME
      ,r.COMP_ID
      ,r.STATUS
      ,r.VERSION
from CDB_REGISTRY r
join v$containers c on c.con_id = r.con_id
order by c.name, r.comp_name;
