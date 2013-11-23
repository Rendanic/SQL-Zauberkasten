--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sqlbind.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Display Bind-Information for given sql_id
--
-- Parameter 1: sql_id
--
set lines 120
set pages 1000

column child_number format 999
column p format 99
column name format a5
column datatype_string format a10
column value_string format a30
column last_captured format a10

select child_number cn
      ,position p
      ,name 
      ,datatype_string typ
      ,value_string
      ,to_char(last_captured,'HH24:MI:SS') LAST
from v$sql_bind_capture
where sql_id = '&1'
order by child_number, position
;

