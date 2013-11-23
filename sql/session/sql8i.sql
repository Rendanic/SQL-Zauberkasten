--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sql8i.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Session Information for SID with running SQL-Statement
-- usable from 8i onwards
--
-- Parameter 1: Oracle SessionID
--
select 
	s.sid
  , s.username
  , s.lockwait
  , s.logon_time
  , sq.executions
  ,	s.machine
  , s.osuser
  , sq.sql_text 
from
	v$session s, v$open_cursor c, v$sql sq
where 
      	s.sid = c.sid (+)and
      	s.username = c.user_name (+) and
      	c.address (+) = s.sql_address and
      	c.saddr (+) = s.saddr and
       c.address  = sq.address
      and	s.sid = &&1
;

