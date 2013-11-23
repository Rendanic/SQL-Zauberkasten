--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: details.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Deploy audit purge for 7 days
-- sys.aud$ is moved to SYSAUX-Tablespace
--  
-- ##############################################
-- #  NO WARRANTY FROM Opitz-Consulting         #                            
-- #  only for educational purposes!!!!!        #
-- ##############################################
--
-- New Feature DBMS_AUDIT_MGMT To Manage And Purge Audit Information [ID 731908.1]
-- SCRIPT: Basic example to manage AUD$ table in 11.2 with dbms_audit_mgmt [ID 1362997.1]
-- Usable without additional Patches from Version: 10.2.0.5, 11.1.0.7 and 11.2.0.1

define default_cleanup_interval=24*7
define Audit_Trail_purge_job='AUDIT_TRAIL_PURGE'
define audit_archive_timestamp=7
define Audit_Trail_archive_job='advance_audit_archive_timestp'

PROMPT DBMS_AUDIT_MGMT.INIT_CLEANUP
begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_AUD_STD,
default_cleanup_interval => &default_cleanup_interval);
end;
/

prompt set last archive timestamp to a week before now

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => sysdate - 7);
exception
	when others then
	if sqlcode not in(46263)
	then
		raise;
	end if;
end;
/


prompt setup a purge job

BEGIN
DBMS_AUDIT_MGMT.DROP_PURGE_JOB
(AUDIT_TRAIL_PURGE_NAME => '&Audit_Trail_purge_job');
 exception
 when others then
 null;
end;
/


BEGIN
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
AUDIT_TRAIL_PURGE_INTERVAL => 24,
AUDIT_TRAIL_PURGE_NAME => '&Audit_Trail_purge_job',
USE_LAST_ARCH_TIMESTAMP => TRUE );
END;
/

PROMPT Drop existing scheduler job &Audit_Trail_archive_job
begin
  DBMS_SCHEDULER.disable('&Audit_Trail_archive_job');
  DBMS_SCHEDULER.drop_job('&Audit_Trail_archive_job');
 exception
 when others then
 null;
end;
/

prompt Optionally Schedule automatic advancement of the archive timestamp

create or replace procedure set_audit_archive_retention
(retention in number default 7) as
begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => sysdate - retention);
end;
/

prompt Create new scheduler Job &Audit_Trail_archive_job

BEGIN
   DBMS_SCHEDULER.create_job (
   job_name => '&Audit_Trail_archive_job',
   job_type => 'STORED_PROCEDURE',
   job_action => 'set_audit_archive_retention',
   number_of_arguments => 1,
   start_date => SYSDATE,
   repeat_interval => 'freq=daily' ,
   enabled => false,
   auto_drop => FALSE);
   dbms_scheduler.set_job_argument_value
    (job_name =>'&Audit_Trail_archive_job',
     argument_position =>1,
     argument_value => '&audit_archive_timestamp');
--   DBMS_SCHEDULER.ENABLE('&Audit_Trail_archive_job');
End;
/

PROMPT Execute the Scheduler-Job
BEGIN
    DBMS_SCHEDULER.run_job (job_name => '&Audit_Trail_archive_job',
    use_current_session => FALSE);
END;
/
