--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sysmetric_history.sql 248 2010-11-23 20:18:21Z tbr $
--
-- Information from v$sysmetric_history for last 10 minutes
--
set echo off
column name format a8

with data
as (select a.metric_id,a.metric_name,a.metric_unit, avg(value) wert
    from v$sysmetric_history a
    where begin_time > sysdate-10/1440
    group by a.metric_id, a.metric_name, a.metric_unit
    order by metric_name
   )
select (select round(a1.wert/100,2) from data a1 where a1.metric_id = 2123
       )DB_s
      ,(select round(a1.wert/100,2) from data a1 where a1.metric_id = 2075
       ) CPU_s
      ,(select round(a1.wert/100,2) from data a1 where a1.metric_id = 2146
       )IO_cnt_s
from dual
;
