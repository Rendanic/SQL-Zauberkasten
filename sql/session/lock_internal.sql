--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: lock_internal.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Information from dba_lock_internal
--

set lines 140 pages 1000
column lock_type format a30
column MODE_HELD format a15
column MODE_REQUESTED format a15
column LOCK_ID1 format a90
column LOCK_ID2 format a40
column SID format 99999

select SESSION_ID SID
      ,LOCK_TYPE
      ,MODE_HELD
      ,MODE_REQUESTED
      ,LOCK_ID1
      ,LOCK_ID2
from DBA_LOCK_INTERNAL
where 1=1
and session_id ='&1'
and MODE_REQUESTED not in ('None')
and lock_type not in ('Media Recovery')
and mode_held not in ('Null')
order by 4,1,3
;
