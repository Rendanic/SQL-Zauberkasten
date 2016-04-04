--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- List all non background session with ocked object informations
-- Date 03.03.2016
-- Version 1
--
set lines 145 pages 200

--column status  format
column sid format 99999
column bssid format 99999
column serial# format 99999
column siw format 99999
column SQL_ID format a13
column state format a13
column event format a30
column RWR format  999
column ROW_BLOCK format 99999999


select status
      ,sid
      ,serial#
      ,SECONDS_IN_WAIT siw
      ,decode(state
             ,'WAITED SHORT TIME', 'SHORT TIME'
             ,'WAITING', decode(event, 'SQL*Net message from client', 'Idle Session')
             ,state) state
      ,event
      ,BLOCKING_SESSION BSSID
      ,SQL_ID
      ,ROW_WAIT_ROW# RWR
      ,ROW_WAIT_BLOCK# ROW_BLOCK
      ,ROW_WAIT_FILE# file#
      ,ROW_WAIT_OBJ# OBJ_ID
from v$session
where ROW_WAIT_OBJ# <> -1
  and type != 'BACKGROUND'
order by status desc, SECONDS_IN_WAIT desc
;

