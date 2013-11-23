--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: jobrun.sql 69 2010-03-15 20:20:53Z tbr $
--
-- list running jobs from dba_jobs
--
set lines 120 pages 100
set trimspool on

column sid format 99999
column job format 9999999
column failures format a99
column last_date format a19
column last_sec format a8
column this_date format 
column this_sec
column instance format 99

select /*+RULE*/ sid
      ,job
      ,failures
      ,to_char(last_date,'dd.mm.yy hh24:mi:ss') last_date
      ,last_sec
      ,to_char(this_date,'dd.mm.yy hh24:mi:ss') this_date
      ,this_sec
      ,instance
  from dba_jobs_running
;

