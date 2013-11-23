--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplansys.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for current session, switching to sys before
--
-- Parameter 1: sql_id
--
@@cs sys
set pages 2000
set lines 200
column PLAN_TABLE_OUTPUT format a200

select * from table(dbms_xplan.display());

