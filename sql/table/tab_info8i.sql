--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_info8i.sql 10 2008-11-11 10:25:06Z oracle $
--
-- display table information from data-dictionary
--

set lines 200
set pages 200
set verify off

column table_name format a30
column f_blk format 999999
column owner format a20
column tablespace_name format a20
column blocks format 9999999
column rowl format 999999
column pfr format 99

select a.owner
     , a.table_name
     , a.tablespace_name
     , a.blocks
     , a.num_rows
     , a.pct_free pfr
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from dba_tables a, dba_tablespaces dt
where a.owner like ('%&1')
  and a.table_name like ('&2')
  and dt.tablespace_name(+) = a.tablespace_name
union all
select a.table_owner
     , a.table_name||' ' || partition_name table_name
     , a.tablespace_name
     , a.blocks
     , a.num_rows
     , a.pct_free
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from dba_tab_partitions a, dba_tablespaces dt
where table_owner like ('%&1')
  and table_name like ('&2')
  and  dt.tablespace_name = a.tablespace_name
order by owner, table_name
;

