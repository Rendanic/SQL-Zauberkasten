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

select v.status
      ,v.inst_id ii
      ,v.sid
      ,v.serial#
      ,v.SECONDS_IN_WAIT siw
      ,v.event
      ,sl.sid BSSID
      ,sl.inst_id BI
      ,nvl(v.SQL_ID, 'P:'||v.prev_sql_id)
      ,v.ROW_WAIT_ROW# RWR
      ,v.ROW_WAIT_BLOCK# ROW_BLOCK
      ,v.ROW_WAIT_FILE# file#
      ,v.ROW_WAIT_OBJ# OBJ_ID
from gv$session v
left outer join gv$lock dw on dw.sid = v.sid
                          and dw.request <> 0
                          and dw.inst_id = v.inst_id
left outer join gv$lock sl on dw.id1 = sl.id1
                          and dw.id2 = sl.id2
                          and dw.type = sl.type
                          and sl.block <> 0
where v.type != 'BACKGROUND'
order by status desc, SECONDS_IN_WAIT desc
;

