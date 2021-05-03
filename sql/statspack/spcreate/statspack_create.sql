--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: statspack_create.sql 55 2010-03-13 09:18:15Z tbr $
--
-- --------------------------------------------------------------------------
-- This script creates the Statspack Schema
-- It must be run on the database server AS SYSDBA
-- *********** Runs on Oracle >= 11.2 ************
-- For Oracle < 11.2 install necessary jobs with statspack_job.sql
-- --------------------------------------------------------------------------
--
-- 2021-05-03 U. Kuechler: Add index for faster querying of SQL Text
-- 2019-09-09 U. Kuechler: Use Scheduler instead of DBMS_JOB
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

PROMPT Setting parameters and taking a first snapshot...
exec statspack.snap(i_snap_level => &snaplevel, i_modify_parameter => 'TRUE')

PROMPT Creating Jobs for Snapshot-Creation. Must be done with instance
PROMPT stickyness for RAC-Databases!

declare
  v_job_name VARCHAR2(30);
  instcnt PLS_INTEGER;
begin
  select count(*) into instcnt from gv$instance;
  if instcnt > 1 then -- -------------------------------- RAC
    for cur_inst in(
      select instance_number from gv$instance
    )
    loop
      v_job_name := 'STATSPACK_SNAP_'||cur_inst.instance_number;
      dbms_scheduler.create_job( job_name => v_job_name
        , job_type => 'STORED_PROCEDURE'
        , job_action => '"PERFSTAT"."STATSPACK"."SNAP"'
        , repeat_interval => 'FREQ=HOURLY; BYMINUTE=55'
        --, start_date => to_timestamp_tz('2019-09-06 17:30:00 Europe/Berlin', 'YYYY-MM-DD HH24:MI:SS TZR')
        , comments => 'Take Statspack snapshot'
        , auto_drop => FALSE
        , enabled => FALSE);
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
        ( name      => v_job_name
         ,attribute => 'INSTANCE_ID'
         ,value     => TO_NUMBER(cur_inst.instance_number));
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
        ( name      => v_job_name
         ,attribute => 'INSTANCE_STICKINESS'
         ,value     => TRUE);
      SYS.DBMS_SCHEDULER.ENABLE
        ( name      => v_job_name);
    end loop;
  else -- -------------------------------- Single Instance
      dbms_scheduler.create_job( job_name => 'STATSPACK_SNAP'
        , job_type => 'STORED_PROCEDURE'
        , job_action => '"PERFSTAT"."STATSPACK"."SNAP"'
        , repeat_interval => 'FREQ=HOURLY; BYMINUTE=55'
        --, start_date => to_timestamp_tz('2019-09-06 17:30:00 Europe/Berlin', 'YYYY-MM-DD HH24:MI:SS TZR')
        , comments => 'Take Statspack snapshot'
        , auto_drop => FALSE
        , enabled => TRUE);
  end if;
end;
/

set pages 1000 lines 140

column job format 9999
column what format a40
column interval format a30
column ins format 999

select * from stats$statspack_parameter;
show parameter job_queue_processes
SELECT job_name, last_start_date, next_run_date, enabled FROM user_scheduler_jobs;

-- Re-fill STATS$IDLE_EVENT with latest idle events that Oracle
-- regularly forgets to update.
delete from STATS$IDLE_EVENT;
insert into STATS$IDLE_EVENT select name from V$EVENT_NAME where wait_class='Idle';
commit;

-- OPTIONAL: Faster querying of SQL Text by sql_id
create index STATS$SQLTEXT_UK1 on STATS$SQLTEXT(sql_id, piece);


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
   AND I.VERSION BETWEEN '12.1' AND '20';
