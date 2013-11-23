prompt Parameter 1: Index-Owner
prompt Parameter 2: Index-Name
----
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_frag_bitmap.sql 84 2010-03-23 20:09:21Z tbr $
--
-- list bitmap-indexes with blevel>2 and leaf_blocks < 100000
--
set lines 120
set pages 1000
set verify off
column table_owner format a20
column index_name format a30
column table_name format a30
column bl format 99
column leaf_blocks format 9999999

select a.table_owner
     , a.table_name
     , a.index_name
     , a.blevel bl
     , a.leaf_blocks
     , to_char(last_analyzed, 'dd.mm.yy HH24:MI') last_analyzed
from dba_indexes a
where index_type ='BITMAP'
  and (blevel > 2 and leaf_blocks < 100000)
  and table_owner like '&1'
  and index_name like '&2'
union all
select a.owner
      , a.table_name
      , a.index_name || ' ' || partition_name
      , b.blevel
      , b.leaf_blocks
      , to_char(last_analyzed, 'dd.mm.yy HH24:MI') last_analyzed
from dba_part_indexes a
join dba_ind_partitions b on a.owner= b.index_owner and a.index_name = b.index_name
join dba_indexes c on a.owner = c.owner and a.index_name = c.index_name
where c.index_type ='BITMAP'
  and (b.blevel > 2 and b.leaf_blocks < 100000)
  and c.table_owner like '&1'
  and c.index_name like '&2'
;
