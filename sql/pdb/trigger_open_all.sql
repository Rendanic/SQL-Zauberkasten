
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 25.11.2013
--
-- Create Trigger for starting all pluggable databases
--
CREATE OR REPLACE TRIGGER OPEN_ALL_PDBS
after startup on database
begin
	execute immediate 'alter pluggable database all open';
end;
/

