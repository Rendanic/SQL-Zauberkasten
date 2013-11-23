--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dict.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays info from DICT
--
prompt Parameter 1: Table-Name

set lines 120
set pages 100
set verify off


column table_name format a30
column comments format a80

select table_name
      ,comments
  from dict
 where table_name like '%&1%'
order by table_name 
;
