--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date: 14.10.2018
--
-- automatic SWitch to Singletenant PDB
--
-- Show some informations about all PDBs and switch to the
-- PDB. This will only work in environments with 1 PDB except PDB$SEED.
-- Use switch.sql <PDB> for Multitenant environments
--
@@vpdb

set feedback off
set serverout on
declare
  v_pdb v$pdbs.name%type;
begin
  dbms_output.enable(10000);
  select name 
    into v_pdb
    from v$pdbs 
   where name <> 'PDB$SEED';

  execute immediate 'alter session set container=' || v_pdb;
exception
  when TOO_MANY_ROWS then
    dbms_output.put_line('Found more then 1 PDB. Please use switch.sql <PDB> instead of sws.sql');
end;
/
set feedback on
set termout off
define gname=idle
column global_name new_value gname
col global_name noprint
select upper(sys_context ('userenv', 'instance_name') || ':' || sys_context('userenv', 'con_name')) global_name from dual;
set sqlprompt '_user @ &gname:>'
set termout on
