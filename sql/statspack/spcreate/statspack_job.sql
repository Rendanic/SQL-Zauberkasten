--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: statspack_job.sql 436 2012-06-09 05:46:37Z tbr $
--
-- script for generating the needed statspack jobs - RAC aware!
-- statspack_configuration.sql must be executed before starting this script!
--
-- Anpassung aufgrund folgender Metalink Note:
-- 361342.1 Subject:    Dump In msqsub() When Querying V$SQL_PLAN
--
-- erforderlich fuer Datenbanken < 10.2.0.4
-- 'alter session set "_cursor_plan_unparse_enabled"=false scope=memory'


conn / as sysdba

grant create job to perfstat;

conn perfstat/&perfstat_password
set echo off
PROMPT Creating Scheduler-Job for purge of statspack-Snapshots

 begin
  begin
    dbms_scheduler.drop_job('perfstat.purge');
  exception
  when others then null;
  end;
  dbms_scheduler.create_job(job_name            => 'PERFSTAT.PURGE'
                           ,job_type            => 'PLSQL_BLOCK'
                           ,job_action          => 'PERFSTAT.STATSPACK.PURGE(&purgedates);'
                           ,repeat_interval     => 'FREQ=daily;byhour=3;byminute=0;bysecond=0'
                           ,enabled             => true
                           ,comments            => 'Statspack Purge Job'
                           );
end;
/


PROMPT Creating Jobs for Snapshot-Creation. Must be done with dbms_job due to instance
PROMPT stickyness for RAC-Databasese!


declare 
jobno number;
begin
  for cur_inst in(
  select instance_number from gv$instance
  )
  loop
     dbms_job.submit(jobno
               , 'begin execute immediate ''alter session set "_cursor_plan_unparse_enabled" = false''; statspack.snap(&snaplevel); end;'
               , trunc(sysdate+1/24,'HH')
               , 'trunc(SYSDATE+1/24,''HH'')'
               , TRUE
               , cur_inst.instance_number);
     commit;
  end loop;
end;
/

set pages 1000 lines 140

column job format 9999
column what format a40
column interval format a30
column ins format 999
select job,what,interval,instance ins from all_jobs;

show parameter job_queue_processes

set pages 1000 lines 140

column job format 9999
column what format a40
column interval format a30
column ins format 999
select job,what,interval,instance ins from all_jobs;

