--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_parallel.sql 10 2008-11-11 10:25:06Z oracle $
--
-- display all parallel attributes from tables and indexes
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
--
set lines 120
set pages 1000

column table_name format a30
column owner format a20

select a.owner
     , a.table_name
     , a.degree
     , a.INSTANCES
 from dba_tables a
where owner like upper('%&1')
  and table_name like upper('&2')
  and (nvl(ltrim(rtrim(degree)),'1') not in('0','1')   or nvl(ltrim(rtrim(instances)), '0') not in ('0','1') )
;


