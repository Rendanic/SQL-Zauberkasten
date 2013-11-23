--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: vbackup_async.sql 221 2010-11-01 21:33:50Z tbr $
--
-- Metalink: Note:237083.1 Subject: 	Using V$BACKUP_ASYNC_IO / V$BACKUP_SYNC_IO to Monitor RMAN Performance
--
-- statistical information from v$backup_async_io
--
set lines 140
set pages 100
column filename format a70

select *
from (select 
       --device_type "Device", 
       type, 
       filename, 
       to_char(open_time, 'dd.mm.yy hh24:mi:ss') open,
       to_char(close_time,'hh24:mi:ss') close,
       elapsed_time ET, 
       round(effective_bytes_per_second/1024) kbytes
from v$backup_async_io
where close_time > sysdate - 30
order by open_time
)
where rownum < 400
;
