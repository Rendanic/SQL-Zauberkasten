--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerwindow.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Note:368475.1 Subject: 	How To Extend Maintenance Windows For GATHER_STATS_JOB for More Than 8 Hours?

column DURATION format a20
column START_DATE format a15
column END_DATE format a15
column RESOURCE_PLAN format a15
column WINDOW_NAME format a15

select WINDOW_NAME
      ,RESOURCE_PLAN 
     , START_DATE
      ,REPEAT_INTERVAL
      ,END_DATE
      ,DURATION
      ,ENABLED
      ,ACTIVE
  from dba_scheduler_windows
;
