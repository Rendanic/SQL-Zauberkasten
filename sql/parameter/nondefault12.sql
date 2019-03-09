--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.com)
--
-- Displays all non default Parameter for CDB & PDB
--
-- Version: 1
-- Date: 09.03.2019
--
-- Important information!
-- Some changed parameters inside a PDB are not shown in v$system_parameter
-- There are visible in PDB_SPFILE$ but that view is not visible
-- with SELECT_CATALOG_ROLE...

set pages 1000
set lines 140
set trimspool on

column id format 99
column pdbname format a20
column name format a30
column value format a60

select vs.inst_id id
      ,decode(vs.con_id
               , 0
               , 'CDB$ROOT'
               , vc.name) pdbname
      ,vs.name
      ,vs.value
from GV$SYSTEM_PARAMETER2 vs
left outer join v$containers vc on vs.con_id = vc.con_id
where isdefault='FALSE' 
order by vs.name,vc.name, vs.inst_id, vs.value
;
