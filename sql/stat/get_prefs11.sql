--
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.de)
--
-- Get default global statistics collection parameters (11g+)
--
-- See also on MOS:
-- FAQ: Automatic Statistics Collection (Doc ID 1233203.1)

col value for a50
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
select 'PUBLISH', DBMS_STATS.get_prefs( 'PUBLISH' ) AS pref FROM dual
union
select 'INCREMENTAL', DBMS_STATS.get_prefs( 'INCREMENTAL' ) AS pref FROM dual
union
select 'STALE_PERCENT', DBMS_STATS.get_prefs( 'STALE_PERCENT' ) AS pref FROM dual
union
select 'CONCURRENT', DBMS_STATS.get_prefs( 'CONCURRENT' ) AS pref FROM dual
/* -- >= 11.2.0.4 only (or Patch 12/18 on 11.2.0.2/.3) ---------------------------------
union
select 'APPROXIMATE_NDV', DBMS_STATS.get_prefs( 'APPROXIMATE_NDV' ) AS pref FROM dual
union
select 'TABLE_CACHED_BLOCKS'
     , CASE DBMS_STATS.get_prefs( 'TABLE_CACHED_BLOCKS' )
       WHEN '0' THEN 'Auto'
       ELSE DBMS_STATS.get_prefs( 'TABLE_CACHED_BLOCKS' )
       END AS pref FROM dual
------------------------------------------------------------------------------------- */
;
