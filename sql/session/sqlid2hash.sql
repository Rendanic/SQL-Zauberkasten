--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 17.07.2015
--
-- get OLD_HASH_VALUE for sqlid from sqlarea
--
-- Parameter 1: SQLID
--
set lines 120
set pages 100
set verify off

column OLD_HASH_VALUE format 99999999999
column sql_id format a13
column vc format 9999

select gs.OLD_HASH_VALUE
      ,gs.SQL_ID
      ,gs.version_count vc
from gv$sqlarea gs
where gs.sqlid = '&1'
;

