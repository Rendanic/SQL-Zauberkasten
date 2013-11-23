--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: stop_sqltrace.sql 253 2010-11-23 21:34:55Z tbr $
--
-- disable SQL-Trace for a given Session
--
prompt Parameter:
prompt 1. Oracle SID
prompt 2. Session#

begin
  dbms_system.SET_SQL_TRACE_IN_SESSION(&1, &2,false);
end;
/

