--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Displays infos for given LOB-Segment
--
-- Date 11.02.2016
--
set lines 140
set pages 100
set verify off


column TABLE_NAME format a30
column owner format a30
column column_name format a30
column cache format a5
column tablespace_name format a30


select owner
      ,table_name
      ,column_name
      ,in_row
      ,cache
      ,tablespace_name
from dba_lobs a
where  a.owner like ('%&1')
  and a.table_name like ('&2')
;
