
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 2
-- Date   : 36.09.2015
--
-- Create Trigger for starting all pluggable databases
--
-- This is only needed for 12.1.0.1. Please do not use it in
-- 12.1.0.2 or newer as these versions has an enhancement SQL
-- syntax for enable/disable autostart of PDBs while starting
-- the instance
--
CREATE OR REPLACE TRIGGER OPEN_ALL_PDBS
after startup on database
begin
	execute immediate 'alter pluggable database all open';
end;
/

