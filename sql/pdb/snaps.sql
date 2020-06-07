--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 07.06.2020
--
-- Display information about PDB Snapshots
--

set lines 120
set pages 100
set verify off


column NAME format a20
column DBID format 999999999999
column PARENT format a20
column status format a13

select v.NAME
      ,v2.NAME "PARENT"
      ,v.DBID
      ,v.OPEN_MODE
      ,v.restricted
      ,v.RECOVERY_STATUS RECOVERY
  from v$pdbs v
 left outer join v$pdbs v2 on v.SNAPSHOT_PARENT_CON_ID = v2.CON_ID
order by 1, 2;