--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- info from dba_waiters with parameter
--
-- Parameter 1: <SID> for session or -1 for list of all entries from dba_waiters
--
-- Date: 07.03.2016
-- Version 1


set lines 145
set pages 30

column WAITS format 99999
column HOLDS format 99999
column LOCK_ID1 format 9999999999
column LOCK_ID2 format 9999999999
column MODE_REQUESTED format a30
column MODE_HELD format a20
column LOCK_TYPE format a13

select WAITING_SESSION WAITS
      ,HOLDING_SESSION HOLDS
      ,LOCK_TYPE
      ,MODE_HELD
      ,MODE_REQUESTED
      ,LOCK_ID1
      ,LOCK_ID2
  from dba_waiters
 where (&1 = -1) or (&1 = WAITING_SESSION)
 order by mode_held, HOLDING_SESSION
;
