--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_archive_stat.sql 221 2010-11-01 21:33:50Z tbr $
--
-- Statistics for archivelog backups
--
set pages 100
set lines 120

column STATUS format a10
column etime format a20
column lzeit format 999999

select 
       trunc(end_time) etime
     , object_type, status
     , round(sum((end_time-start_time))*24*60) lzeit
     , round(sum(input_bytes)/1024/1024) imb
     , round(sum(output_bytes)/1024/1024) omb
from(
select *
from V$RMAN_STATUS
where operation='BACKUP'
)
group by trunc(end_time)
        , object_type, status
order by etime
;
