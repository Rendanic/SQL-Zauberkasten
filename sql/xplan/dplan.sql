--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplan.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for last explain in current session
--
set pages 2000
set lines 200
column PLAN_TABLE_OUTPUT format a200

select * from table(dbms_xplan.display());

