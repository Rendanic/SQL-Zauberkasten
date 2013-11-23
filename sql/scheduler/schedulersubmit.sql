--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulersubmit.sql 10 2008-11-11 10:25:06Z oracle $
--
begin
   dbms_scheduler.create_job(job_name            => '&JOB_NAME'
                            ,job_type            => 'PLSQL_BLOCK'
                            --,job_type            => 'STORED_PROCEDURE'
                            ,job_action          => '&PLSQLPROCEDURE'
                            ,repeat_interval     => null
                            ,enabled             => false
                            ,comments            => 'einmalig ausgefuehrter Job'
                            );
end;
/

