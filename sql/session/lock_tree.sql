-- Abhängigkeitsbaum blockierter Sessions aehnlich utllockt.sql, jedoch
-- RAC-aware und mit Details
--
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.com)
-- Thorsten Bruhns (thorsten.bruhns@opitz-consulting.com)
--
-- Date: 07.06.2016

col wsid for a6
col inst_id for a2
col username for a10
col winst format 99
col osuser for a10
col module for a10
col action for a10
set lines 200 pages 50000 trimspool on

with BLOCKERS as(
  SELECT inst_id waiting_instance
       , sid waiting_session
       , blocking_instance
       , blocking_session
    FROM gv$session
   WHERE blocking_instance IS NOT NULL AND blocking_session IS NOT NULL
)
, LOCK_TREE as(
  select * from BLOCKERS 
  union all
  select blocking_instance, blocking_session, null, null
    from BLOCKERS
  minus
  select waiting_instance, waiting_session, null, null
    from BLOCKERS
)
select lpad(' ', 2*(level-1)) || l.waiting_session wsid
     , l.waiting_instance winst
     , s.status
     , SUBSTR( q.sql_text, 1, 30 ) sql_text
     , COALESCE( S.SQL_ID, S.PREV_SQL_ID ) sql_id
     , s.OSUSER
     , s.USERNAME
     , SUBSTR(s.PROGRAM,1,20) program
     , SUBSTR(s.module,1,20) module
     , s.action
  from LOCK_TREE l
     , gv$session s
     , gv$sql q
 where s.sid = l.waiting_session
   and s.inst_id = l.waiting_instance
   and q.sql_id (+) = coalesce( s.sql_id, s.prev_sql_id )
   and q.inst_id (+) = s.inst_id
connect by prior l.waiting_session = l.blocking_session
       and prior l.waiting_instance = l.blocking_instance
  start with l.blocking_session is null;
