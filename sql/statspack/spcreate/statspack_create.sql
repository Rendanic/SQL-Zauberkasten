--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: statspack_create.sql 55 2010-03-13 09:18:15Z tbr $
--
-- This script creates the statspack-Schema
-- It must be run on the database-server
--
-- 2015-09-03 U. Kuechler: Re-fill STATS$IDLE_EVENT with latest idle events
-- 2016-06-23 U. Kuechler: Check for missing column bug in 12.1
-- 2015-09-03 U. Kuechler: Jobnr. ausgeben; doppeltes SQL entfernt.
-- Anpassung aufgrund folgender Metalink Note:
-- 361342.1 Subject:    Dump In msqsub() When Querying V$SQL_PLAN
--
-- erforderlich fuer Datenbanken < 10.2.0.4
-- 'alter session set "_cursor_plan_unparse_enabled"=false scope=memory'


PROMPT Parsing Parameters
whenever oserror exit 1 rollback
@@statspack_configuration.sql

PROMPT Creating Statspack-Objects
@?/rdbms/admin/spcreate

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
PROMPT stickyness for RAC-Databases!

set serveroutput on
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
     dbms_output.put_line('Job #'||jobno||' created.');
  end loop;
end;
/

set pages 1000 lines 140

column job format 9999
column what format a40
column interval format a30
column ins format 999

show parameter job_queue_processes

select job,what,interval,instance ins from all_jobs;

-- Re-fill STATS$IDLE_EVENT with latest idle events that Oracle
-- regularly forgets to update.
delete from STATS$IDLE_EVENT;
insert into STATS$IDLE_EVENT select name from V$EVENT_NAME where wait_class='Idle';
commit;

-- Check for missing column bug in 12.1
set feedback off
  WITH c AS( 
SELECT COUNT(column_name) nt FROM dba_tab_columns
 WHERE owner = 'PERFSTAT' and table_name = 'STATS$SQL_PLAN' and column_name = 'TIMESTAMP')
     , I as (select version from v$instance)
SELECT 'Missing Column "TIMESTAMP" in table "STATS$SQL_PLAN"!'||CHR(10)||
       'You might consider adding it by issuing:'||CHR(10)||
       'ALTER TABLE perfstat.stats$sql_plan ADD timestamp INVISIBLE AS (cast(NULL AS DATE));'
       as WARNING
  FROM c, I
 WHERE c.nt = 0
   AND I.VERSION BETWEEN '12.1' AND '12.2';
