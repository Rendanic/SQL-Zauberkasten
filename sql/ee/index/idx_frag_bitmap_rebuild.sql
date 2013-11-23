prompt Parameter 1: Index-Owner
prompt Parameter 2: Index-Name
----
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_frag_bitmap_rebuild.sql 100 2010-04-01 05:50:23Z tbr $
--
-- 'alter index .. rebuild online' for  bitmap-indexes with blevel>2 
-- and leaf_blocks < 100000
-- Attention! Only usable in Enterprise Edition!
--
--
set lines 120
set pages 1000
set verify off
column table_owner format a20
column index_name format a30
column table_name format a30
column bl format 99
column leaf_blocks format 9999999

select 'alter index '||owner||'.'||index_name ||' rebuild online;'
from dba_indexes a
where index_type ='BITMAP'
  and (blevel > 2 and leaf_blocks < 100000)
  and PARTITIONED='NO'
  and table_owner like '&1'
  and index_name like '&2'
union all
select 'alter index '||owner||'.'||index_name ||' partition '||partition_name||' rebuild online;'
from dba_part_indexes a
join dba_ind_partitions b on a.owner= b.index_owner and a.index_name = b.index_name
join dba_indexes c on a.owner = c.owner and a.index_name = c.index_name
where c.index_type ='BITMAP'
  and (b.blevel > 2 and b.leaf_blocks < 100000)
  and c.table_owner like '&1'
  and c.index_name like '&2'
;
