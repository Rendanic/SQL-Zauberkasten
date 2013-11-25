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

