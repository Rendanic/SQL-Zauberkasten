--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- 
-- Version: 1
-- Date: 2019.10.29
--
-- Show pending statistics from tables
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
set lines 200
set pages 200
set verify off

column table_name format a30
column f_blk format 999999
column owner format a20
column blocks format 99999999
column rowl format 999999
column num_rows format 999999999
column pfr format 99
column analyzed format a14

select a.owner
     , a.table_name
     , a.blocks
     , round(a.num_rows) num_rows
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from DBA_TAB_PENDING_STATS a
where owner like ('%&1')
  and table_name like ('&2')
;
