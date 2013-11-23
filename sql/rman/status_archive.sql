--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_archive.sql 221 2010-11-01 21:33:50Z tbr $
--
-- history for known archivelog backups
--
set pages 100
set lines 120

column STATUS format a10
column etime format a14
column stime format a14
column lzeit format 999999

select to_char(start_time, 'dd.mm.yy HH24:mi') stime
     , to_char(end_time, 'dd.mm.yy HH24:mi') etime
     , round((end_time-start_time)*24*60) lzeit
     , object_type, status
     , round(input_bytes/1024/1024) imb
     , round(output_bytes/1024/1024) omb
from(
select *
from V$RMAN_STATUS
where operation='BACKUP'
  and object_type = 'ARCHIVELOG'
order by start_time desc)
where rownum < 60
order by start_time
;
