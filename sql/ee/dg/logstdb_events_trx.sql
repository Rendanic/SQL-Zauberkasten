 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: logstdb_events_trx.sql 103 2010-04-01 13:49:14Z tbr $
-- Displays trx-ids from DBA_LOGSTDBY_EVENTS


-- How to skip a transaction in a logical standby:
-- exec dbms_logstdby.SKIP_TRANSACTION( XIDUSN_P,XIDSLT_P,XIDSQN_P)

set longchunksize 1000
set long 1000
set pages 100
set lines 120

column event_time format a14
column status format a60
column event format a40

SELECT to_char(EVENT_TIME, 'dd.mm hh24:mi:ss') event_time
     , STATUS
     , XIDUSN
     , XIDSLT
     , XIDSQN
FROM DBA_LOGSTDBY_EVENTS 
ORDER BY EVENT_TIMESTAMP, COMMIT_SCN
;
