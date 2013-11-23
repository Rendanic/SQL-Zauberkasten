--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: ind_stale.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display stale Index Statistics
--
-- Parameter 1: Owner (searched with like)
-- Parameter 2: Table-Name (searched with like)


set lines 200
set pages 200
set verify off

column table_name format a30
column index_name format a30
column f_blk format 999999
column owner format a20
column tablespace_name format a20
column blocks format 99999999
column rowl format 999999
column pfr format 99

select a.owner
     , a.table_name
     , a.index_name
     , b.tablespace_name
     --, round(100-(((a.num_rows*a.AVG_ROW_LEN)/nvl(dt.block_size,1))/decode(nvl(a.blocks,0),0,0.1,a.blocks))*100) frag_pct
     , round(a.num_rows) num_rows
     , b.pct_free pfr
     , a.STALE_STATS stal
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from DBA_IND_STATISTICS a
 join dba_tables b on a.owner = b.owner and a.table_name = b.table_name
 left outer join dba_tablespaces dt on dt.tablespace_name = b.tablespace_name
where a.owner like ('%&1')
  and a.table_name like ('&2')
  and a.stale_stats = 'YES'
order by owner, table_name
;

