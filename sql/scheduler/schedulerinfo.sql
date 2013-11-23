--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerinfo.sql 10 2008-11-11 10:25:06Z oracle $
--
set lines 140
set pages 100

column owner format a20
column job_name format a20
column REPEAT_INTERVAL format a20
column SCHEDULE_NAME format a20
column STATE format a9

select owner
      ,job_name
      ,to_char(NEXT_RUN_DATE, 'dd.mm.yy hh24:mi:ss') NEXT_RUN_DATE
      ,to_char(LAST_START_DATE, 'dd.mm.yy hh24:mi:ss') LAST_START_DATE
      ,REPEAT_INTERVAL
      ,enabled
      ,SCHEDULE_NAME
      ,STATE
  from DBA_SCHEDULER_JOBS
order by 1,2;
