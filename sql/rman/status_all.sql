--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_all.sql 221 2010-11-01 21:33:50Z tbr $
--
-- status for all RMAN-Backups from v$rman_status
--
set pages 100
set lines 120
set trimspool on
set feedback off

column STATUS format a10
column etime format a14
column stime format a14
column lmin format 99999
column recid format 999999
column lv format 99
column operation format a15

select lv, recid, to_char(start_time, 'dd.mm.yy HH24:mi') stime
     , to_char(end_time, 'dd.mm.yy HH24:mi') etime
     , round((end_time-start_time)*24*60) lmin
     , operation
     , object_type
     , status
     , round(input_bytes/1024/1024) imb
     , round(output_bytes/1024/1024) omb
from (
      select * 
      from (
            select *
            from (
                  select rownum rn, level lv, a.*
                  from v$rman_status a
                  connect by prior recid = parent_recid
                  start with parent_recid is null
                  order siblings by start_time
                )
            order by rn desc
           )
      where rownum < 251
      )
order by rn
;
