--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: resumable.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Display Resumable Sessions 
--

set lines 120
set pages 200

column session_id format 999999
column status format a9
column timeout format 99999
column suspend_time format a15
column error_msg format a40

select a.SESSION_ID
     , a.status
     , a.TIMEOUT
     , a.SUSPEND_TIME
     , a.ERROR_MSG
  from dba_resumable a
;

