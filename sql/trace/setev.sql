--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: setev.sql 253 2010-11-23 21:34:55Z tbr $
--
-- enable a SQL-Trace for a given session with level
--
prompt tracelevels:
prompt 1  - Enable standard SQL_TRACE functionality (Default)
prompt 4  - As Level 1 PLUS trace bind values
prompt 8  - As Level 1 PLUS trace waits
prompt 12 - As Level 1 PLUS both trace bind values and waits
prompt Parameter:
prompt 1. Oracle SID
prompt 2. Session#

begin
  dbms_system.set_ev(&1,&2,10046,&tracelevel,'');
end;
/
@@list_traces
