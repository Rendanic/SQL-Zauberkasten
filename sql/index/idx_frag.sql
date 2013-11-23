prompt Parameter 1: Index-Owner
prompt Parameter 2: Index-Name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_frag.sql 482 2012-09-19 14:27:18Z tbr $
--
-- List indizes ordered by fragmentation
-- Attention! The fragmentation is calculated on top of the index statistics
--            The result is wrong for indexes with high avg_col_length
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
set echo off
set trimspool off
set lines 120
set pages 1000
set verify off

column owner format a20
column table_name format a30
column index_name format a30
column bl format 99
column leaf_blk format 9999999
column num_rows format 999999999
column frag format 99
column avgrl format 999

select d.owner
      ,d.table_name
      ,d.index_name
      ,d.blevel bl
      ,d.leaf_blocks leaf_blk
      ,d.num_rows
      ,round(100-d.PCT_FREE-(sum(b.AVG_COL_LEN)+8)*d.num_rows/e.block_size/d.leaf_blocks*100,1) frag
      ,sum(b.AVG_COL_LEN) avgrl
from dba_indexes d
join dba_ind_columns c on d.owner = c.index_owner
                      and d.index_name = c.index_name
join DBA_TAB_COL_STATISTICS b on d.owner = b.owner
                             and d.table_name = b.table_name
                             and c.column_name = b.column_name
join dba_tablespaces e on e.tablespace_name = d.tablespace_name
where d.owner like '&1'
  and d.index_name like '&2'
  and d.leaf_blocks > 10
  and d.index_type in ('NORMAL', 'NORMAL/REV')
group by d.owner
      ,d.table_name
      ,d.index_name
      ,d.blevel
      ,d.leaf_blocks
      ,d.num_rows
      ,e.block_size
      ,d.PCT_FREE
order by 7
;
