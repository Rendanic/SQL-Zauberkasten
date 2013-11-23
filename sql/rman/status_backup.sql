--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_backup.sql 10 2008-11-11 10:25:06Z oracle $
--
-- list entries from v$rman_status where object_type != 'ARCHIVELOG'

set pages 100
set lines 120
set verify off
set trimspool on

column STATUS format a10
column etime format a14
column stime format a14
column lzeit format 999999
column imb format 9999999
column omb format 9999999

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
  and object_type != 'ARCHIVELOG'
order by start_time desc)
where rownum < 40
order by start_time
;
