--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 30.07.2020
--
-- Information for changes in dba_registry_history
--
set pages 100
set lines 120

column zeit format a14
column ACTION format a10
column NAMESPACE format a10
column VERSION format a22
column comments format a50

select to_char(ACTION_TIME, 'dd.mm.yy HH24:MI') zeit
      ,ACTION
      ,VERSION
      ,comments
from DBA_REGISTRY_HISTORY
order by action_time;
