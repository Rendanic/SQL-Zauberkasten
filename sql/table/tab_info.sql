--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_info.sql 249 2010-11-23 20:20:00Z tbr $
--
-- display table information from data-dictionary
-- fragmentation is only usable for tables withour LOB-Columns!
-- fragmentation is calculated from table-Statistics!
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
column tablespace_name format a20
column blocks format 99999999
column rowl format 999999
column num_rows format 999999999
column pfr format 99
column analyzed format a14

select a.owner
     , a.table_name
     , a.tablespace_name
     , round(100-(((num_rows*AVG_ROW_LEN)/nvl(dt.block_size,1))/decode(nvl(a.blocks,0),0,0.1,a.blocks))*100) frag_pct
     , a.blocks
     , round(a.num_rows) num_rows
     , a.pct_free pfr
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from dba_tables a
 left outer join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('%&1')
  and table_name like ('&2')
union all
select a.table_owner
     , a.table_name||' ' || partition_name table_name
     , a.tablespace_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/decode(nvl(a.blocks,0),0,0.1,a.blocks))*100) frag_pct
     , a.blocks
     , a.num_rows
     , a.pct_free
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from dba_tab_partitions a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where table_owner like ('&1')
  and table_name like ('&2')
order by owner, table_name
;

