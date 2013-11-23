--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tabmodification.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Information from dba_tab_modifications
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
set pages 100
set lines 140

column table_owner format a20
column partition_name format a20
column ins format 999999999999
column del format 999999999999
column upd format 999999999999

select table_owner
      ,table_name
      ,partition_name
      ,inserts ins
      ,updates upd
      ,deletes del
      ,to_char(timestamp, 'DD.MM.YY HH24:MI') zeit
  from dba_tab_modifications
 where table_owner like '&1'
   and table_name like '&2'
order by 1,2
;

