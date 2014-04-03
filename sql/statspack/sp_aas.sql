-- Parameter 1: DB-ID
--
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.de)
-- $Id: spsnap_dbid.sql 57 2010-03-13 10:00:31Z tbr $
--
-- Display Average Active Sessions over time, with simple graph
--

set lines 120 pages 9999 echo off verify off

column inst format 99
column aas_graph format a41
column aas format 999,99
SELECT snap_time
     , instance_number as inst
     , RPAD('|', CEIL( 40* aas / max(aas) over() ), '*') aas_graph
     , ROUND( aas, 2 ) aas
FROM
(
  SELECT ( LEAD( tm.value, 1 ) OVER( ORDER BY tm.snap_id ) - tm.value ) /
         DECODE( ( LEAD( sn.snap_time, 1 ) OVER( ORDER BY sn.snap_id ) - sn.snap_time ), 0, NULL
         , ( LEAD( sn.snap_time, 1 ) OVER( ORDER BY sn.snap_id ) - sn.snap_time ) )
         / 24 / 3600 / 1000000 AS aas
       , sn.snap_time
       , sn.instance_number
    FROM stats$sys_time_model tm
       , stats$time_model_statname nm
       , stats$snapshot sn
   WHERE tm.stat_id = nm.stat_id
     AND nm.stat_name = 'DB time'
     AND sn.snap_id = tm.snap_id
)
 WHERE aas IS NOT NULL
 ORDER BY snap_time, instance_number;
