--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: registry.sql 60 2010-03-13 11:20:37Z tbr $
--
-- Information for changes in dba_registry_history
--
set pages 100
set lines 100

column zeit format a17
column ACTION format a10
column NAMESPACE format a10
column VERSION format a12
column comments format a30

select to_char(ACTION_TIME, 'dd.mm.yy HH24:MI') zeit
      ,ACTION
      ,NAMESPACE
      ,VERSION
      ,comments
from DBA_REGISTRY_HISTORY
order by action_time;
