--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: log_hist_stat1.sql 421 2012-04-11 19:21:52Z tbr $
--
-- Statistic Information for Archivelog volume of last 10 days
--
set pages 80
set lines 120
column dest_id format 99
column time_h24 format a20
column size_mb format 9999999

select dest_id
      ,to_char(time_h24,'dd.mm.yy hh24') time_h24
      ,count
from (
select dest_id
      ,trunc(first_time,'HH24') time_h24
      ,count(1) count
from (select 
            first_time
            ,thread#
            ,sequence#
            ,resetlogs_change#
            ,first_change#
            ,blocks
            ,block_size
            ,dest_id
        from gv$archived_log
       order by RESETLOGS_CHANGE# desc, first_change# desc
     )
group by dest_id, trunc(first_time,'HH24')
order by 2,1
)
;

