--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Date: 23.12.2015
--
-- export ddl for a give job with dbms_job
--
-- This script must be run as the job owner!
--
-- 1. Parameter : jobid from dba_jobs

set lines 4000
set pages 0
set trimspool on
set heading off
set verify off
set feedback off

set serverout on
set lines 1000 pages 1000 verify off
declare
    jobtxt varchar2(5000);
begin
    dbms_job.user_export(&1, jobtxt);
    dbms_output.enable(1000000);
    dbms_output.put_line('-- job_owner: '|| user);
    dbms_output.put_line('exec ' || jobtxt);
end;
/

set feedback on
set heading on
