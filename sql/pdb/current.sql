--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 25.11.2013
--
-- Get current PDB from session
--

set lines 120
set pages 100
set verify off

select sys_context ( 'Userenv', 'Con_Name') "Container DB" from dual;
