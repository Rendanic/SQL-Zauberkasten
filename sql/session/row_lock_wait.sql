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
column BSSID format 99999
column serial# format 99999
column siw format 99999
column SQL_ID format a13
column state format a13
column event format a30
column RWR format  999
column ROW_BLOCK format 99999999


select v.status
      ,v.sid
      ,v.serial#
      ,v.SECONDS_IN_WAIT siw
      ,decode(v.state
             ,'WAITED SHORT TIME', 'SHORT TIME'
             ,'WAITING', decode(v.event, 'SQL*Net message from client', 'Idle Session')
             ,v.state) state
      ,v.event
      ,sl.sid BSSID
      ,v.SQL_ID
      ,v.ROW_WAIT_ROW# RWR
      ,v.ROW_WAIT_BLOCK# ROW_BLOCK
      ,v.ROW_WAIT_FILE# file#
      ,v.ROW_WAIT_OBJ# OBJ_ID
from v$session v
left outer join v$lock dw on dw.sid = v.sid 
                          and dw.request <> 0
left outer join gv$lock sl on dw.id1 = sl.id1
                          and dw.id2 = sl.id2
                          and dw.type = sl.type
                          and sl.block <> 0
where v.type != 'BACKGROUND'
order by v.status desc, v.SECONDS_IN_WAIT desc
;

