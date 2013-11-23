--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: job_purge.sql 467 2012-09-07 07:37:53Z tbr $
--
-- script for generating the purge job
-- statspack_configuration.sql must be executed before starting this script!
--
-- Anpassung aufgrund folgender Metalink Note:
-- 361342.1 Subject:    Dump In msqsub() When Querying V$SQL_PLAN
--
-- erforderlich fuer Datenbanken < 10.2.0.4
-- 'alter session set "_cursor_plan_unparse_enabled"=false scope=memory'

grant create job to perfstat;

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
