--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: beispiele.sql 10 2008-11-11 10:25:06Z oracle $
--
-- window anlegen

begin
  dbms_scheduler.create_window_group(group_name         => 'TESTWINDOW'
                                    ,window_list        => null
                                    ,comments           => null
                                    );
end;

exec dbms_scheduler.enable('')

exec dbms_scheduler.run_job()
exec dbms_scheduler.stop_job()

attribze aender:

begin
  dbms_scheduler.set_attribute(name         => ''
                              ,attribute    => ''
                              ,value        => 
                              );
end;

moegliche Attribute:
logging_level => DBMS_SCHEDULER.LOGGING_OFF 
                 DBMS_SCHEDULER.LOGGING_RUNS
                 DBMS_SCHEDULER.LOGGING_FULL
max_failures      => integer between 1 to 1,000,000
                     default NULL
max_runs          => integer between 1 to 1,000,000
                     default NULL
max_run_duration
job_weight        => degree of parallelism  for SQL
instance_stickiness
stop_on_window_close      => TRUE/FALSE
job_priority              => 1 .. 5 default 3 kleiner = hoehere Prioritaet
program_name
job_action
job_type
number_of_arguments
schedule_name
repeat_interval
start_date
end_date
job_class
comments
auto_drop



