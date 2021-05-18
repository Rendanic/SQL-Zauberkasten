-- get_prefs.sql
-- SUPERSEDES get_param.sql
--
-- get global optimizer statistics gathering preferences from database
--
-- Note:725845.1 Subject: How to Change Default Parameters for Gathering Statistics
--
-- 2021-05-18 U. Kuechler: Cover options from 10.1 to 19c.

set lines 80 trimspool on pages 50000 feed off
col value for a30

with I as (select version from v$instance)
select 'AUTOSTATS_TARGET' AS pref, DBMS_STATS.get_prefs( 'AUTOSTATS_TARGET' ) AS value FROM dual
union
select 'CASCADE', DBMS_STATS.get_prefs( 'CASCADE' ) AS pref FROM dual
union
select 'DEGREE'
     , CASE DBMS_STATS.get_prefs( 'DEGREE' ) 
       WHEN NULL THEN 'Null'
       WHEN '32767' THEN 'Default'
       WHEN '32768' THEN 'Auto'
       ELSE DBMS_STATS.get_prefs( 'DEGREE' )
       END AS pref FROM dual
union
select 'ESTIMATE_PERCENT'
     , CASE DBMS_STATS.get_prefs( 'ESTIMATE_PERCENT' )
       WHEN '0' THEN 'Auto'
       ELSE DBMS_STATS.get_prefs( 'ESTIMATE_PERCENT' )
       END AS pref FROM dual
union
select 'METHOD_OPT', DBMS_STATS.get_prefs( 'METHOD_OPT' ) AS pref FROM dual
union
select 'NO_INVALIDATE', DBMS_STATS.get_prefs( 'NO_INVALIDATE' ) AS pref FROM dual
union
select 'GRANULARITY', DBMS_STATS.get_prefs( 'GRANULARITY' ) AS pref FROM dual
union
select 'PUBLISH', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_prefs( 'PUBLISH' )
       ELSE '---' END AS pref FROM dual, i
union
select 'INCREMENTAL', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_prefs( 'INCREMENTAL' )
       ELSE '---' END AS pref FROM dual, i
union
select 'STALE_PERCENT', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_prefs( 'STALE_PERCENT' )
       ELSE '---' END AS pref FROM dual, i
union
select 'CONCURRENT', CASE WHEN I.VERSION >= '11.2'
       THEN DBMS_STATS.get_prefs( 'CONCURRENT' )
       ELSE '---' END AS pref FROM dual, i
--/* ab 11.2.0.4 oder 11.2.0.3 mit Patch 13262857 ------------------------------
union
select 'APPROXIMATE_NDV', CASE WHEN I.VERSION >= '11.2.0.4'
       THEN DBMS_STATS.get_prefs( 'APPROXIMATE_NDV' )
       ELSE '---' END AS pref FROM dual, i
union
select 'TABLE_CACHED_BLOCKS'
     , CASE WHEN I.VERSION >= '11.2.0.4' THEN 
           CASE DBMS_STATS.get_prefs( 'TABLE_CACHED_BLOCKS' )
           WHEN '0' THEN 'Auto'
           ELSE DBMS_STATS.get_prefs( 'TABLE_CACHED_BLOCKS' )
           END
       ELSE '---' 
       END AS pref FROM dual, i
--/* ab 12.1 -------------------------------------------------------------------
union
select 'GLOBAL_TEMP_TABLE_STATS', CASE WHEN I.VERSION >= '12.1'
       THEN DBMS_STATS.get_prefs( 'GLOBAL_TEMP_TABLE_STATS' )
       ELSE '---' END AS pref FROM dual, i
union
select 'INCREMENTAL_LEVEL', CASE WHEN I.VERSION >= '12.1'
       THEN DBMS_STATS.get_prefs( 'INCREMENTAL_LEVEL' )
       ELSE '---' END AS pref FROM dual, i
union
select 'INCREMENTAL_STALENESS', CASE WHEN I.VERSION >= '12.1'
       THEN DBMS_STATS.get_prefs( 'INCREMENTAL_STALENESS' )
       ELSE '---' END AS pref FROM dual, i
union
select 'OPTIONS', CASE WHEN I.VERSION >= '12.1'
       THEN DBMS_STATS.get_prefs( 'OPTIONS' )
       ELSE '---' END AS pref FROM dual, i
--/* ab 12.2 -------------------------------------------------------------------
union
select 'APPROXIMATE_NDV_ALGORITHM', CASE WHEN I.VERSION >= '12.2'
       THEN DBMS_STATS.get_prefs( 'APPROXIMATE_NDV_ALGORITHM' )
       ELSE '---' END AS pref FROM dual, i
union
select 'AUTO_STAT_EXTENSIONS', CASE WHEN I.VERSION >= '12.2'
       THEN DBMS_STATS.get_prefs( 'AUTO_STAT_EXTENSIONS' )
       ELSE '---' END AS pref FROM dual, i
union
select 'PREFERENCE_OVERRIDES_PARAMETER', CASE WHEN I.VERSION >= '12.2'
       THEN DBMS_STATS.get_prefs( 'PREFERENCE_OVERRIDES_PARAMETER' )
       ELSE '---' END AS pref FROM dual, i
union
select 'STAT_CATEGORY', CASE WHEN I.VERSION >= '12.2'
       THEN DBMS_STATS.get_prefs( 'STAT_CATEGORY' )
       ELSE '---' END AS pref FROM dual, i
union
select 'WAIT_TIME_TO_UPDATE_STATS', CASE WHEN I.VERSION >= '12.2'
       THEN DBMS_STATS.get_prefs( 'WAIT_TIME_TO_UPDATE_STATS' )
       ELSE '---' END AS pref FROM dual, i
--/* ab 19 ---------------------------------------------------------------------
union
select 'AUTO_TASK_INTERVAL', CASE WHEN I.VERSION >= '19'
       THEN DBMS_STATS.get_prefs( 'AUTO_TASK_INTERVAL' )
       ELSE '---' END AS pref FROM dual, i
union
select 'AUTO_TASK_MAX_RUN_TIME', CASE WHEN I.VERSION >= '19'
       THEN DBMS_STATS.get_prefs( 'AUTO_TASK_MAX_RUN_TIME' )
       ELSE '---' END AS pref FROM dual, i
union
select 'AUTO_TASK_STATUS', CASE WHEN I.VERSION >= '19'
       THEN DBMS_STATS.get_prefs( 'AUTO_TASK_STATUS' )
       ELSE '---' END AS pref FROM dual, i
union
select 'ROOT_TRIGGER_PDB', CASE WHEN I.VERSION >= '19'
       THEN DBMS_STATS.get_prefs( 'ROOT_TRIGGER_PDB' )
       ELSE '---' END AS pref FROM dual, i
------------------------------------------------------------------------------*/
;
