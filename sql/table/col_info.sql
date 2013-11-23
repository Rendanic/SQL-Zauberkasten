--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: col_info.sql 10 2008-11-11 10:25:06Z oracle $
--
-- search for columns in data dictionary
-- 
-- Parameter 1: Owner
-- Parameter 2: Table-Name
-- Parameter 3: Column-Name
--

column owner format a30
column table_name format a30
column column_name format a30
set lines 120
set pages 200

select owner
      ,table_name
      ,column_name
  from dba_tab_columns
 where owner like '&1'
   and column_name like '&2'
order by owner, table_name, column_name
;

