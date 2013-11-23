--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: restorepoint.sql 221 2010-11-01 21:33:50Z tbr $
--
-- display known restore points
--
set lines 120
set pages 200

column NAME format a50
column Zeit format a17
column dbinc format 999999
column size format 999999
column scn format 999999999999
select scn
      ,DATABASE_INCARNATION# dbinc
      ,GUARANTEE_FLASHBACK_DATABASE GUA
      ,STORAGE_SIZE/1024/1024 "size"
      ,to_char(TIME, 'dd.mm.yy HH24:mi:SS') Zeit
      ,NAME
from V$RESTORE_POINT
order by TIME
;

