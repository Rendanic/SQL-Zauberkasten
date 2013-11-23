--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplanawr.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for sql_id from AWR
--
-- Parameter 1: sql_id
--
set pages 2000
set lines 200
set trimspool on

column PLAN_TABLE_OUTPUT format a200

select * from table(dbms_xplan.DISPLAY_AWR('&1'));

