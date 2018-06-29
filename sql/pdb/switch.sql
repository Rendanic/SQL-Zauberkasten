--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 25.11.2013
--
-- Set session to container
--
-- Parameter 1: PDB-Name


set lines 120
set pages 100
set verify off

alter session set container = &1;

set termout off
define gname=idle
column global_name new_value gname
col global_name noprint
select upper(sys_context ('userenv', 'instance_name') || ':' || sys_context('userenv', 'con_name')) global_name from dual;
set sqlprompt '_user @ &gname:>'
set termout on
