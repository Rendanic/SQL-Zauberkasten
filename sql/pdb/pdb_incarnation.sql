--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 26.09.2015
--
-- Display information for PDB Incarnations
--

set lines 120
set pages 100
set verify off


column NAME format a30
column CID format 999
column status format a10

select i.CON_ID CID
     , decode(i.con_id, 1, 'CDB$ROOT', p.name) name
     , i.STATUS
     , to_char(i.INCARNATION_TIME, 'dd.mm.yy hh24:mi:ss') INCARNATION
     , to_char(i.BEGIN_RESETLOGS_TIME, 'dd.mm.yy hh24:mi:ss') BEGIN_RESETLOGS
     , to_char(i.END_RESETLOGS_TIME, 'dd.mm.yy hh24:mi:ss') END_RESETLOGS
from v$pdb_incarnation i
left outer join v$pdbs p on i.con_id = p.con_id
order by i.con_id, i.INCARNATION_SCN
;
