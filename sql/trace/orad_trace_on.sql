--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: orad_trace_on.sql 253 2010-11-23 21:34:55Z tbr $
--
-- Enable SQL-Trace in current oradebug session
--
prompt tracelevels:
prompt 1  - Enable standard SQL_TRACE functionality (Default)
prompt 4  - As Level 1 PLUS trace bind values
prompt 8  - As Level 1 PLUS trace waits
prompt 12 - As Level 1 PLUS both trace bind values and waits

oradebug event 10046 trace name context forever, level &tracelevel
oradebug TRACEFILE_NAME
