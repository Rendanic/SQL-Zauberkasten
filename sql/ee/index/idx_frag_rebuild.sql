-- Parameter 1: Index-Owner
-- Parameter 2: Index-Name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_frag_rebuild.sql 100 2010-04-01 05:50:23Z tbr $
--
-- 'alter index .. rebuild online;' for fragemnted indexes
-- Attention! The fragmentation is calculated on top of the index statistics
--            The result is wrong for indexes with high avg_col_length
--
set lines 120
set pages 1000
set verify off
column owner format a20
column table_name format a30
column index_name format a30
column bl format 99
column leaf_blocks format 999999
column num_rows format 999999999
column frag format 99
column avgrl format 999

select 'alter index '||owner||'.'||index_name||' rebuild online;'
from (
select a.owner
      ,a.table_name
      ,a.index_name
      ,a.blevel bl
      ,a.leaf_blocks
      ,a.num_rows
      ,round(100-(sum(b.AVG_COL_LEN)+8)*a.num_rows/e.block_size/a.leaf_blocks*100,1) frag
      ,sum(b.AVG_COL_LEN) avgrl
from dba_ind_statistics a
join dba_ind_columns c on a.owner = c.index_owner
                      and a.index_name = c.index_name
join DBA_TAB_COL_STATISTICS b on a.owner = b.owner
                             and a.table_name = b.table_name
                             and c.column_name = b.column_name
join dba_indexes d on d.owner = a.owner
                  and d.index_name = a.index_name
join dba_tablespaces e on e.tablespace_name = d.tablespace_name
where a.owner like '&1'
  and a.index_name like '&2'
  and a.leaf_blocks > 10
  and d.index_type in ('NORMAL', 'NORMAL/REV')
group by a.owner
      ,a.table_name
      ,a.index_name
      ,a.blevel
      ,a.leaf_blocks
      ,a.num_rows
      ,e.block_size
order by 7
)
;
