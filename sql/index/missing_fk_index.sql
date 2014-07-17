--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Date: 17.07.2014
--
-- List missing index columns from Foreign Keys
-- Attention! This SQL is not 100% safe. Partitioned Tables produces wrong 
--            results!
-- Parameter 1: Owner
--
set echo off
set trimspool off
set lines 120
set pages 1000
set verify off

column owner format a20
column table_name format a30
column column_name format a30
column position format 3

SELECT * FROM (
SELECT c.owner, c.table_name, cc.column_name, cc.position column_position
FROM   all_constraints c, all_cons_columns cc
WHERE  c.constraint_name = cc.constraint_name
AND    c.constraint_type = 'R'
AND    c.owner = cc.owner
and    c.owner like '&1'
and c.owner not in ('SYS', 'SYSTEM', 'EXFSYS', 'DBSNMP', 'PERFSTAT')
MINUS
SELECT i.owner, i.table_name, ic.column_name, ic.column_position
FROM   all_indexes i, all_ind_columns ic
WHERE  i.index_name = ic.index_name
  and  i.owner = Ic.index_owner
)
ORDER BY owner, table_name, column_position;
