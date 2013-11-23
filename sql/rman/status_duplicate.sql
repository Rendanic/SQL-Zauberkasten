--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_duplicate.sql 30 2010-01-12 20:58:11Z oracle $
--
-- list duplicate operations from v$rman_status

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
PROMPT ACHTUNG! lv ist umgekehrt sortiert!

select lv, recid, to_char(start_time, 'dd.mm.yy HH24:mi') stime
     , to_char(end_time, 'dd.mm.yy HH24:mi') etime
     , round((end_time-start_time)*24*60) lzeit
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
                      connect by prior parent_recid = recid
                      start with operation = 'DUPLICATE DB'
                      order siblings by start_time
                )
            order by rn desc
           )
      where rownum < 251
      )
order by rn
;
