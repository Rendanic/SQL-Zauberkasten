-- Abhängigkeitsbaum blockierter Sessions aehnlich utllockt.sql, jedoch
-- RAC-aware und mit Details
--
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.com)
-- Thorsten Bruhns (thorsten.bruhns@opitz-consulting.com)

col sid for a10
col inst_id for a2
col username for a10
col osuser for a10
col module for a10
col action for a10
col kill_session_stmt for a55
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
select lpad(' ', 2*(level-1)) || l.waiting_session sid
     , l.waiting_instance inst_id
     , s.status
     , SUBSTR( q.sql_text, 1, 30 ) sql_text
     , COALESCE( S.SQL_ID, S.PREV_SQL_ID ) sql_id
     , s.OSUSER
     , s.USERNAME
     , 'alter system kill session ' || '''' || s.SID || ', ' || s.serial# || ', @' || s.inst_id ||'''' || ' immediate;' kill_session_stmt
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
