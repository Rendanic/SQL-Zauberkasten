--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_rman_backup.sql 221 2010-11-01 21:33:50Z tbr $
--
-- list last 50 entries from v$rman_status
--
--
set pages 100
set lines 120
set verify off
set trimspool on

column imb format 9999999
column omb format 9999999
column STATUS format a10
column etime format a14
column stime format a14
column lzeit format 999999
column lv format 99
column operation truncate format a23
column recid   format 999999

select db_name
     , to_char((start_time), 'dd.mm.yy HH24:mi') stime
     , to_char(end_time, 'dd.mm.yy HH24:mi') etime
     , round((end_time-start_time)*24*60) lzeit
     , object_type, status
     , round(input_bytes/1024/1024) imb
     , round(output_bytes/1024/1024) omb
from(
select *
from RC_RMAN_STATUS
where (DB_KEY,DBINC_KEY,recid) 
             in(select DB_KEY,DBINC_KEY,recid 
                from rc_rman_status
               where (DB_KEY,DBINC_KEY,start_time)
                     in(select DB_KEY,DBINC_KEY,max(start_time)
                        from rc_rman_status
                       where operation='BACKUP'
                       and object_type != 'ARCHIVELOG'
                       group by (DB_KEY,DBINC_KEY)
                      )
               )
)
order by db_name
;
