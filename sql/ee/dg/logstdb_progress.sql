 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: logstdb_progress.sql 156 2010-07-30 07:33:37Z tbr $
-- Displays information from V$LOGSTDBY_PROGRESS

alter session set nls_date_format='dd.mm.yy hh24:mi:ss';
set lines 120

column latest_time format a17
column APPLIED_TIME format a17
column RESTART_TIME format a17
column MINING_TIME format a17
select  latest_time
       ,APPLIED_TIME
       ,RESTART_TIME
       ,MINING_TIME 
from  V$LOGSTDBY_PROGRESS;
