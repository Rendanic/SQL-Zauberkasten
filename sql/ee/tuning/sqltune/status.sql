prompt -- 1. Parameter task_name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Status from DBA_ADVISOR_LOG for a task_name
--
set lines 120
set pages 100
set verify off

column status format a20
column status_message format a30
select task_name
      ,status 
      ,substr(STATUS_MESSAGE,1,30) STATUS_MESSAGE
      ,PCT_COMPLETION_TIME pct
      ,PROGRESS_METRIC pm
      --,substr(METRIC_UNITS,1,30) METRIC_UNITS
from dba_advisor_log where task_name like'&1'
order by EXECUTION_END nulls last;


