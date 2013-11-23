--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_shrink.sql 10 2008-11-11 10:25:06Z oracle $
--
-- generates statements for shrinking tables
--
-- 1. Parameter : Owner
-- 2. Parameter : Tabellenname
-- 3. Parameter : Fragmentierungsgrad
--
-- Das Script liefert die Tabellen, bei denen statistisch die Oraclebloecke nur zu 
-- 100-frag_pct gefuellt sind
-- Es werden nur Tabellen mit mehr als 10 Bloecken betrachtet

set lines 2000
set pages 0
set verify off
set heading on
set trimspool on
set feedback off
set timing off

prompt set timing on

select 'alter table '||owner||'.'||table_name||' enable row movement;'
from (
select a.owner
     , a.table_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/nvl(a.blocks,0.00000000001))*100) frag_pct
     , a.blocks
 from dba_tables a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('&1')
  and table_name like ('&2')
order by a.blocks desc, owner, table_name
)
where blocks >= 10
  and frag_pct >= &3
;

select 'alter table '||owner||'.'||table_name||' shrink space compact;'
from (
select a.owner
     , a.table_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/nvl(a.blocks,0.00000000001))*100) frag_pct
     , a.blocks
 from dba_tables a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('&1')
  and table_name like ('&2')
order by a.blocks desc, owner, table_name
)
where blocks >= 10
  and frag_pct >= &3
;

select 'alter table '||owner||'.'||table_name||' shrink space;'
from (
select a.owner
     , a.table_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/nvl(a.blocks,0.00000000001))*100) frag_pct
     , a.blocks
 from dba_tables a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('&1')
  and table_name like ('&2')
order by a.blocks desc, owner, table_name
)
where blocks >= 10
  and frag_pct >= &3
;

select 'exec dbms_stats.gather_table_stats('''||owner||''','''||table_name||''',cascade => true, degree => 4)'
from (
select a.owner
     , a.table_name
     , round(100-(((num_rows*AVG_ROW_LEN)/dt.block_size)/nvl(a.blocks,0.00000000001))*100) frag_pct
     , a.num_rows
     , a.blocks
 from dba_tables a
 join dba_tablespaces dt on dt.tablespace_name = a.tablespace_name
where owner like ('&1')
  and table_name like ('&2')
order by a.blocks desc, owner, table_name
)
where blocks >= 10
  and frag_pct >= &3
;

set feedback on
set verify on

