--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerinfo2.sql 10 2008-11-11 10:25:06Z oracle $
--
set lines 140
set pages 100

column owner format a20
column job_name format a20
column SCHEDULE_NAME format a20
column job_action format a60

select owner
      ,job_name
      ,SCHEDULE_NAME
      ,job_action
  from DBA_SCHEDULER_JOBS
order by 1,2;
