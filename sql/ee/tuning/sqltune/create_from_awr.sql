PROMPT -- Parameter begin_snap
PROMPT -- Parameter end_snap
PROMPT -- Parameter time_limit
PROMPT -- Parameter sql_id
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: create_from_awr.sql 30 2010-01-12 20:58:11Z oracle $
--
-- creates a tuning from AWR-snapshot range
--
-- Metalink Note: 262687.1 How to use the Sql Tuning Advisor.
--
set serverout on
set verify off

declare
  retval    varchar2(32000);
begin
  retval :=
  DBMS_SQLTUNE.CREATE_TUNING_TASK(begin_snap  => &begin_snap
                                 ,end_snap    => &end_snap
                                 ,time_limit  => &time_limit
                                 ,sql_id      => '&sql_id'
                                 ,task_name   => '&task_name'
                                 );
  dbms_output.put_line('retval: ' || nvl(retval,'(null)'));
end;
/

begin
   dbms_scheduler.create_job(job_name            => '&&job_name'
                            ,job_type            => 'PLSQL_BLOCK'
                            ,job_action          => 'dbms_sqltune.Execute_tuning_task (task_name => ''&&task_name'');'
                            ,repeat_interval     => null
                            ,enabled             => false
                            ,comments            => 'Tuning Task fuer Task-Name &&task_name'
                            );
end;
/


