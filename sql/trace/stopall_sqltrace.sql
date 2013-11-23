--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: stopall_sqltrace.sql 253 2010-11-23 21:34:55Z tbr $
--
-- disable SQL-Trace for all sessions in a database
--

begin
  for cur_user in(select sid
                     ,serial#
                from v$session
              )
  loop
    dbms_system.SET_SQL_TRACE_IN_SESSION(cur_user.sid, cur_user.serial#,false);
  end loop;
end;
/

