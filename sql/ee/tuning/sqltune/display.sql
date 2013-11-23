PROMPT -- Parameter 1: tuning task name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: display.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Displays a report for a tuning task
--

set long 1000000
set longchunksize 1000000
set linesize 200
set pages 1000
set verify off

set trimspool on
select dbms_sqltune.report_tuning_task('&1') from dual;

