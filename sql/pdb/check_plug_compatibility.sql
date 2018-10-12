--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 12.10.2018
--
-- Script for checking the pdb plug in compatibility

-- Parameter 1: Filename for xml for plugin

SET SERVEROUTPUT ON
DECLARE
  compatible CONSTANT VARCHAR2(3) := 
         CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
                                   pdb_descr_file => '&1',
                                   pdb_name => 'PDB3')
         WHEN TRUE THEN 'YES' ELSE 'NO'
		 END;
BEGIN
  DBMS_OUTPUT.PUT_LINE(compatible);
END;
/

set pages 100
set lines 200
column message format a100 wrap
select message 
from pdb_plug_in_violations 
where type like '%ERR%' 
  and status <> 'RESOLVED';

