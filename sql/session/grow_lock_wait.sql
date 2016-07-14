--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- List all non background session with locked object informations - RAC aware
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- List all row lock waits over all instances
--
-- Date 14.07.2016
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
column BI format  99
column II format  99
column ROW_BLOCK format 99999999

select status
      ,inst_id ii
      ,sid
      ,serial#
      ,SECONDS_IN_WAIT siw
      ,event
      ,BLOCKING_SESSION BSSID
      ,BLOCKING_INSTANCE BI
      ,SQL_ID
      ,ROW_WAIT_ROW# RWR
      ,ROW_WAIT_BLOCK# ROW_BLOCK
      ,ROW_WAIT_FILE# file#
      ,ROW_WAIT_OBJ# OBJ_ID
from gv$session
where ROW_WAIT_OBJ# <> -1
  and type != 'BACKGROUND'
order by status desc, SECONDS_IN_WAIT desc
;

