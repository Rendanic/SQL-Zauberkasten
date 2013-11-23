--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: alert_thresholds.sql 232 2010-11-13 18:09:48Z tbr $
--
-- Display of all registered alert thresholds
--
set lines 140
set pages 100

column metrics_name format a40
column warn_val format a7
column crit_val format a7
column warn_op format a12
column crit_op format a12
column op format 999
column co format 99
column status format a7
column object_name format a20

select
       metrics_name
      ,WARNING_OPERATOR warn_op
      ,warning_value warn_val
      ,CRITICAL_OPERATOR crit_op
      ,critical_value crit_val
      ,OBSERVATION_PERIOD op
      ,CONSECUTIVE_OCCURRENCES co
      ,status
      ,object_name
  from DBA_THRESHOLDS 
order by metrics_name, object_name nulls first
;
