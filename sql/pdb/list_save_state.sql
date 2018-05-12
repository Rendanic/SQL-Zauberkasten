--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 12.05.2018
--
-- list save state for PDBs
--
set pages 100 lines 120

column con_name format a60
column state format a10
column restricted format a12

select con_name
      ,state
      ,restricted 
from CDB_PDB_SAVED_STATES
order by 1;


