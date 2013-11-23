--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: orad_trace_off.sql 253 2010-11-23 21:34:55Z tbr $
--
-- disable SQL-Trace in current oradebug session
--
oradebug event 10046 trace name context off
