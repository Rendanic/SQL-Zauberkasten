--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sql9.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Session Information for SID with running SQL-Statement
-- usable from 9i onwards
--
-- Parameter 1: Oracle SessionID

select a.sid
      ,a.username
      ,a.lockwait
      ,a.logon_time
      ,a.machine
      ,a.osuser
from v$session a
where a.status = 'ACTIVE'
  and	a.sid = &&1
;
select distinct HASH_VALUE
from  v$session a
join V$SQLTEXT_WITH_NEWLINES b on a.SQL_ADDRESS = b.address
where a.status = 'ACTIVE'
  and   a.sid = &&1
;

column sql_text format a70
select /*+ RULE*/ sql_text
from  v$session a
join V$SQLTEXT_WITH_NEWLINES b on a.SQL_ADDRESS = b.address
where a.status = 'ACTIVE'
  and   a.sid = &&1
order by piece
;
