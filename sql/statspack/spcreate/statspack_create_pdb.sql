--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date: 27.08.2018
--
-- This script creates the statspack-Schema inside a PDB
-- It must be run on the database-server
--
-- Parameter: <PDB-Name>
--
-- Anpassung aufgrund folgender Metalink Note:
-- 361342.1 Subject:    Dump In msqsub() When Querying V$SQL_PLAN
--
-- 'alter session set "_cursor_plan_unparse_enabled"=false scope=memory'


PROMPT Parsing Parameters
whenever oserror exit 1 rollback
@@statspack_configuration.sql

whenever sqlerror exit 1 rollback

set lines 120
set pages 100
set verify off

alter session set container = &1;

set termout off
define gname=idle
column global_name new_value gname
col global_name noprint
select upper(sys_context ('userenv', 'instance_name') || ':' || sys_context('userenv', 'con_name')) global_name from dual;
set sqlprompt '_user @ &gname:>'
set termout on


PROMPT Creating Statspack-Objects
@?/rdbms/admin/spcreate

conn / as sysdba
alter session set container = &1;

grant create job to perfstat;

alter session set current_schema=perfstat;

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

PROMPT Setting parameters and taking a first snapshot...
exec statspack.snap(i_snap_level => &snaplevel, i_modify_parameter => 'TRUE')

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
               , 'begin execute immediate ''alter session set "_cursor_plan_unparse_enabled" = false''; statspack.snap; end;'
               , trunc(sysdate+1/24,'HH')
               , &snapinterval
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

select * from stats$statspack_parameter;
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
