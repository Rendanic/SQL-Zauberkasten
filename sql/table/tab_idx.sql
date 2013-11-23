--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_idx.sql 10 2008-11-11 10:25:06Z oracle $
--
-- display all indexes on a table
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
set lines 120
set pages 1000

column owner format a20
column index_name format a30
column pos format 999
column column_name format a30

select di.owner
      ,di.index_name
      ,dic.column_name
      ,dic.column_position pos
  from dba_indexes di
     , DBA_IND_COLUMNS dic 
 where di.table_owner  like(('&1'))
   and di.table_name  like(( '&2'))
   and dic.table_owner = di.table_owner                                                 
                      and dic.table_name = di.table_name
                      and dic.index_name = di.index_name
order by di.table_owner, di.table_name, di.index_name, dic.column_position
;

