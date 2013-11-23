--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulersubmit_external.sql 10 2008-11-11 10:25:06Z oracle $
--
begin
   dbms_scheduler.create_job(job_name            => '&JOB_NAME'
                            ,job_type            => 'EXECUTABLE'
                            ,job_action          => '&script'
                            ,repeat_interval     => null
                            ,enabled             => false
                            ,comments            => 'einmalig ausgefuehrter Job'
                            );
end;
/

