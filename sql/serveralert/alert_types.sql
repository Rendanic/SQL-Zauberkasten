--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: alert_types.sql 224 2010-11-03 06:15:31Z tbr $
--
-- Lists all Types from V$ALERT_TYPES
--
set lines 120
set pages 1000
column group_name format a20
column scope format a8
column internal_metric_category format a30
column internal_metric_name format a30

select group_name
      , scope
      , internal_metric_category
      , internal_metric_name
from V$ALERT_TYPES
order by group_name, internal_metric_name
;

