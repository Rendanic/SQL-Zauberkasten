--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: alerts.sql 232 2010-11-13 18:09:48Z tbr $
--
-- List of actual alerts
--
set lines 120
set pages 100
set feedback off


column alert_level format a12
column reason format a70
column zeit format a17

select to_char(TIME_SUGGESTED, 'dd.mm.yy HH24:mi:ss') Zeit
     , decode(message_level, 5, 'WARNING', 1, 'CRITICAL') alert_level
     , reason 
  from dba_outstanding_alerts;

set feedback on
