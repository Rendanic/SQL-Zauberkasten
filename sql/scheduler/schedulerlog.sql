--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerlog.sql 10 2008-11-11 10:25:06Z oracle $
--
set pages 100
set lines 125
column ldate format a17
column owner format a20
column job_name format a30
column status format a10
column additional_info format a30
column lzeit format a13

select  to_char(log_date, 'dd.mm.yy HH24:mi:ss') ldate
     , owner
     , job_name
     , status
     , to_char(duration, 'HH24:MM:SS') lzeit
     , additional_info
from
(
select *
from (
select log_date
     , owner
     , job_name
     , status
     , run_duration duration
     , additional_info
from DBA_SCHEDULER_JOB_RUN_DETAILS
where owner like '&1'
  and job_name like '&2'
)
order by log_date desc
) where rownum < 100
order by log_date
;
