--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerrun.sql 10 2008-11-11 10:25:06Z oracle $
--
column SESSION_STAT_CPU format a17
column owner format a30
column object_name format a30
column session_id format 99999
column SESSION_SERIAL_NUM format 99999

select session_id
      ,SESSION_SERIAL_NUM
      ,SESSION_STAT_CPU
      ,owner
      ,object_name
from V$SCHEDULER_RUNNING_JOBS vs
join dba_objects db on vs.JOB_ID = db.OBJECT_ID
;
