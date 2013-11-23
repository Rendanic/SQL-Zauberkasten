--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: hash2sqlid.sql 459 2012-09-02 18:13:26Z tbr $
--
-- get sqlid for OLD_HASH_VALUE from sqlarea
--
-- Parameter 1: OLD_HASH_VALUE
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
where gs.old_hash_value = '&1'
;

