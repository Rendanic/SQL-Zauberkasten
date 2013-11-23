--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: alertall.sql 232 2010-11-13 18:09:48Z tbr $
--
-- List of all old and actual alerts
--

set feedback off
set echo off
@@alert_history
PROMPT aktuelle Alerts
@@alerts
