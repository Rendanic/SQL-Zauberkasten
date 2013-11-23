--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_frag.sql 10 2008-11-11 10:25:06Z oracle $
--
-- display table fragmentation, attention on tables with LOBs!
-- Attention with LOB-Columns on tables. The result is wrong on such tables
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
-- Das Script liefert die Tabellen, bei denen statistisch die Oraclebloecke nur zu 
-- 100-frag_pct gefuellt sind
-- Es werden nur Tabellen mit mehr als 10 Bloecken betrachtet
--

set lines 200
set pages 200
set verify off

column tablespace_name format a20
column f_blk format 999999
column owner format a20
column tablespace_name format a20
column blocks format 9999999
column rowl format 999999

select *
from (
select a.owner
     , a.table_name
     , a.tablespace_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/nvl(a.blocks,0.00000000001))*100) frag_pct
     , a.blocks
     , a.num_rows
     , a.AVG_ROW_LEN rowl
     , to_char(a.last_analyzed, 'dd.MM.YY HH24:MI') analyzed
 from dba_tables a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('&1')
  and table_name like ('&2')
order by a.blocks desc, owner, table_name
)
where blocks >= 10
  and frag_pct >= &3
;

