-- Parameter 1: Index-Owner
-- Parameter 2: Index-Name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_rebuild_unusable.sql 100 2010-04-01 05:50:23Z tbr $
--
-- 'alter index .. rebuild online;' for unusable indexes
-- Only usable with Enterprise-Edition
--

set lines 1000
set pages 0
set feedback off
set trimspool on
set verify off

select 'alter index '||owner||'.'||index_name||' rebuild online;'
  from dba_indexes
 where owner like('&1')
   and index_name like('&2')
   and status = 'UNUSABLE'
   and temporary = 'N'
union all
select 'alter index '||index_owner||'.'||index_name||' rebuild partition '||partition_name||' online;'
  from dba_ind_partitions
 where index_owner like('&1')
   and index_name like('&2')
   and status = 'UNUSABLE'
;


set feedback on

