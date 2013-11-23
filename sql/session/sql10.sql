--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sql10.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Session Information for SID with running SQL-Statement
-- usable from 9i onwards
--
set verify off
column sql_text format a80
select a.sid
      ,a.username
      ,a.lockwait
      ,a.logon_time
      ,a.machine
      ,a.osuser
      ,a.SQL_ID
      ,a.SQL_CHILD_NUMBER
from v$session a
where a.status = 'ACTIVE'
  and   a.sid = &&1
;
 
select 
      b.sql_text      
from v$session a
join V$SQLTEXT_WITH_NEWLINES b on a.SQL_ADDRESS = b.address
                              and a.sql_id = b.sql_id
where a.status = 'ACTIVE'
  and	a.sid = &&1
order by piece
;

