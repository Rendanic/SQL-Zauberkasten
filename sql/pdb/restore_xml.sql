--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 16.05.2021
--
-- Execute dbms_pdb.recover
--
-- Parameter 1: PDB-Name
-- Parameter 2: XML-Filename
-- Parameter 3: Datafile-Location
set lines 120
set pages 100
set verify off

begin
  dbms_pdb.recover(
    pdb_name => '&1',
    pdb_descr_file => '&2',
    filenames => '&3'
  );
end;
/
