-- Parameter 1: DB-ID
--
-- Report of dba_hist_sysmetric_summary
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awr_snap_stats_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--
-- Metalink: Manual querying AWR for trend analysis and capacity planning [ID 422414.1] 
--
alter session set nls_date_format='dd.mm.yy hh24:mi';
set lines 140
set pages 50
set verify off

column snap_id format 999999
column load format 999

select min(begin_time) btime,
       to_char(max(end_time),'hh24:mi') endtime,
       round(sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end)/1024)  Ph_Rd_kB,
       round(sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end)/1024) Ph_Wr_kB,
       round(sum(case metric_name when 'Redo Generated Per Sec' then average end))                  Redo_p_s,
       round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end))  Phy_Rd_IOPS,
       round(sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end)) Phy_wr_IOPS,
       round(sum(case metric_name when 'Redo Writes Per Sec' then average end)) redo_IOPS,
       round(sum(case metric_name when 'Current OS Load' then average end)) LOad,
       round(sum(case metric_name when 'CPU Usage Per Sec' then average end)) DB_CPU_Use, 
       round(sum(case metric_name when 'Host CPU Utilization (%)' then average end)) Host_CPU, --NOTE 100% = 1 loaded RAC node 
       round(sum(case metric_name when 'Network Traffic Volume Per Sec' then average end)) Net_byt_p_s, 
       snap_id
from dba_hist_sysmetric_summary
where dbid = &1
group by snap_id
order by snap_id 
;
