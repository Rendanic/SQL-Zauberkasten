--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Performance Data for all Instances with summary from AWR
--
-- Metalink: Manual querying AWR for trend analysis and capacity planning [ID 422414.1]
--
-- Date: 10.06.2016
AUDIT --

set lines 140
set pages 50
set verify off

column snap_id format 999999
column load format 999
col ii format 99

select instance_number ii,
       to_char(min(begin_time), 'dd.mm hh24:mi') btime,
       to_char(max(end_time),'hh24:mi') endtime,
       round(sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end)/1024)  Ph_Rd_kB,
       round(sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end)/1024) Ph_Wr_kB,
       round(sum(case metric_name when 'Redo Generated Per Sec' then average end)/1024)             Redo_kB,
       round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end))  Phy_Rd_IOPS,
       round(sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end)) Phy_wr_IOPS,
       round(sum(case metric_name when 'Redo Writes Per Sec' then average end)) redo_IOPS,
       round(sum(case metric_name when 'Current OS Load' then average end)) LOad,
       round(sum(case metric_name when 'CPU Usage Per Sec' then average end)) DB_CPU_Use,
       round(sum(case metric_name when 'Host CPU Utilization (%)' then average end)) Host_CPU, --NOTE 100% = 1 loaded RAC node
       round(sum(case metric_name when 'Network Traffic Volume Per Sec' then average end)) Net_byt_p_s,
       snap_id
from dba_hist_sysmetric_summary
group by grouping sets((snap_id,instance_number),(snap_id))
--order by snap_id,instance_number
;

