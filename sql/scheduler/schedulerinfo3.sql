--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerinfo3.sql 10 2008-11-11 10:25:06Z oracle $
--
set lines 140
set pages 100

column owner format a20
column job_name format a20
column SCHEDULE_NAME format a20
column prg format a60
column narg format 99

select owner
      ,job_name
      ,NUMBER_OF_ARGUMENTS narg
      ,program_owner||'.'||PROGRAM_NAME prg
  from DBA_SCHEDULER_JOBS
order by 1,2;
