--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: reset_parameter.sql 93 2010-03-24 04:42:58Z tbr $
--
-- Removes a parameter from spfile for all instances
--
prompt Parameter 1: Parameter

set verify off
alter system reset "&1" scope=spfile sid='*';

