-- Parameter 1: Index-Owner
-- Parameter 2: Index-Name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- display all parallel attributes from tables and indexes
--
-- Date: 19.08.2015
column table_name format a30
column owner format a20

set verify off

select a.owner
     , a.table_name
     , a.index_name
     , a.degree
     , a.INSTANCES
 from dba_indexes a
where owner like '&1'
  and index_name like '&2'
  and (nvl(ltrim(rtrim(degree)),'1') not in('0','1')  or nvl(ltrim(rtrim(instances)), '0') not in ('0','1') )
;


