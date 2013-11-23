--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplanallstatslast.sql 244 2010-11-14 14:35:23Z tbr $
--
-- Display plan for last sql with 'allstats_last'
--
set echo off
set verify off
set feedback off

set feedback on

set pages 2000
set lines 200
set trimspool on

column PLAN_TABLE_OUTPUT format a200

select * 
from table(dbms_xplan.DISPLAY_CURSOR(null,null,'ALLSTATS LAST')) 
;


