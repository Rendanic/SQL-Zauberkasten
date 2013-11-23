PROMPT -- Parameter 1: tuning task name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: journal.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Displays SQL-Monitor Report for given sql_id
--
set long 10000000
set longchunksize 10000000
set linesize 230

select dbms_sqltune.report_sql_monitor(sql_id => '&1') 
from dual;