 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: logstdb_events.sql 102 2010-04-01 13:11:55Z tbr $
-- Displays information from DBA_LOGSTDBY_EVENTS


set longchunksize 1000
set long 1000
set pages 100
set lines 120

column event_time format a14
column status format a60
column event format a40

SELECT to_char(EVENT_TIME, 'dd.mm hh24:mi:ss') event_time
     , STATUS, EVENT 
FROM DBA_LOGSTDBY_EVENTS 
ORDER BY EVENT_TIMESTAMP, COMMIT_SCN
;
