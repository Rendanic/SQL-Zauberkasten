--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Search Hints in V$SQL_HINT
--
-- Date: 03.12.2015
-- Version: 1
-- Parameter 1: Hint-Filter

set lines 120
set pages 100
set verify off

column name format a30

select name
      ,version
  from V$SQL_HINT
 where name like '&1'
order by name 
;
