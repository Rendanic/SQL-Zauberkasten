--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: lob_info.sql 85 2010-03-23 20:11:44Z tbr $
--
-- Displays infos for given LOB-Segment
set lines 120
set pages 100
set verify off


column TABLE_NAME format a30
column owner format a30
column column_name format a30


select owner
      ,table_name
      ,column_name
      ,in_row
from dba_lobs a
where  a.owner like ('%&1')
  and a.table_name like ('&2')
;
