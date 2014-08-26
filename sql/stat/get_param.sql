--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: get_param.sql 10 2008-11-11 10:25:06Z oracle $
--
-- get default statistic parameter from database
--
-- Note:406475.1 Subject: 	What are default parameters when i gather statistisc on Table on 9i and 10g
-- Note:725845.1 Subject:       How to Change Default Parameters for Gathering Statistics
--
-- 2014-08-14 U. Kuechler: Major rewrite to cover options from 10.1 to 11.2.0.4.

col value for a30

with I as (select version from v$instance)
select 'AUTOSTATS_TARGET' AS pref, DBMS_STATS.get_param( 'AUTOSTATS_TARGET' ) AS value FROM dual
union
select 'CASCADE', DBMS_STATS.get_param( 'CASCADE' ) AS pref FROM dual
union
select 'DEGREE'
     , CASE DBMS_STATS.get_param( 'DEGREE' ) 
       WHEN NULL THEN 'Null'
       WHEN '32767' THEN 'Default'
       WHEN '32768' THEN 'Auto'
       ELSE DBMS_STATS.get_param( 'DEGREE' )
       END AS pref FROM dual
union
select 'ESTIMATE_PERCENT'
     , CASE DBMS_STATS.get_param( 'ESTIMATE_PERCENT' )
       WHEN '0' THEN 'Auto'
       ELSE DBMS_STATS.get_param( 'ESTIMATE_PERCENT' )
       END AS pref FROM dual
union
select 'METHOD_OPT', DBMS_STATS.get_param( 'METHOD_OPT' ) AS pref FROM dual
union
select 'NO_INVALIDATE', DBMS_STATS.get_param( 'NO_INVALIDATE' ) AS pref FROM dual
union
select 'GRANULARITY', DBMS_STATS.get_param( 'GRANULARITY' ) AS pref FROM dual
union
select 'PUBLISH', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_param( 'PUBLISH' )
       ELSE '---' END AS pref FROM dual, i
union
select 'INCREMENTAL', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_param( 'INCREMENTAL' )
       ELSE '---' END AS pref FROM dual, i
union
select 'STALE_PERCENT', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_param( 'STALE_PERCENT' )
       ELSE '---' END AS pref FROM dual, i
union
select 'CONCURRENT', CASE WHEN I.VERSION >= '11'
       THEN DBMS_STATS.get_param( 'CONCURRENT' )
       ELSE '---' END AS pref FROM dual, i
--/* ab 11.2.0.4 ---------------------------------------------------------------
union
select 'APPROXIMATE_NDV', CASE WHEN I.VERSION >= '11.2.0.4'
       THEN DBMS_STATS.get_param( 'APPROXIMATE_NDV' )
       ELSE '---' END AS pref FROM dual, i
union
select 'TABLE_CACHED_BLOCKS'
     , CASE WHEN I.VERSION >= '11.2.0.4' THEN 
           CASE DBMS_STATS.get_param( 'TABLE_CACHED_BLOCKS' )
           WHEN '0' THEN 'Auto'
           ELSE DBMS_STATS.get_param( 'TABLE_CACHED_BLOCKS' )
           END
       ELSE '---' 
       END AS pref FROM dual, i
------------------------------------------------------------------------------*/
;
