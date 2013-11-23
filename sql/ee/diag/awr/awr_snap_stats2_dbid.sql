-- Parameter 1: DB-ID
--
-- List a report from dba_hist_sysmetric_summary
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awr_snap_stats2_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--
-- Metalink: Manual querying AWR for trend analysis and capacity planning [ID 422414.1] 
--
alter session set nls_date_format='dd.mm.yy hh24:mi';
set lines 140
set pages 50
set verify off

column snap_id format 999999
column load format 999
column DBCMax format 99999
column HMax format 999
column pct_IO format 999
column IOmax format 999

select min(begin_time) btime,
       to_char(max(end_time),'hh24:mi') endtime,
       round(sum(case metric_name when 'Current OS Load' then average end)) Load,
       round(sum(case metric_name when 'CPU Usage Per Sec' then average end)) DBCPU_Use, 
       round(sum(case metric_name when 'CPU Usage Per Sec' then maxval end)) DBCMax, --NOTE 100% = 1 loaded RAC node 
       round(sum(case metric_name when 'Host CPU Utilization (%)' then average end)) Host_CPU, --NOTE 100% = 1 loaded RAC node 
       round(sum(case metric_name when 'Host CPU Utilization (%)' then maxval end)) HMax, --NOTE 100% = 1 loaded RAC node 
       round(sum(case metric_name when 'Database Wait Time Ratio' then average end)) pct_IO,
       round(sum(case metric_name when 'Database Wait Time Ratio' then maxval  end)) IOmax,
       snap_id
from dba_hist_sysmetric_summary
where dbid = &1
group by snap_id
order by snap_id 
;
