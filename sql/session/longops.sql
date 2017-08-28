--
-- Uwe Kuechler (Uwe.Kuechler@opitz-consulting.de)
--
-- Session Long Operations
-- (more extensive than slo.sql and with progress bar ;-)
--
set pages 9999
set lines 240
col "Elapsed/s" format 999999
col "Remaining/s" format 999999
col message format a90
col progress for a12
col username for a10

SELECT *
  FROM(
    SELECT RPAD('|', 1+ROUND(sofar/NULLIF(totalwork, 0)*10,0), '#') || LPAD('|', 11-ROUND(sofar/NULLIF(totalwork, 0)*10,0), '_') progress
         --, ROUND(sofar/NULLIF(totalwork, 0)*100,0) pct_done
         , elapsed_seconds "Elapsed/s", time_remaining "Remaining/s"
         , username, sid, serial#
         , NVL( sql_id, '[NULL]' ) AS sql_id
         , last_update_time
         -- 11g+ only: -----
         --, sql_exec_start, sql_plan_line_id, sql_exec_id
         -------------------
         , message
      FROM gv$session_longops
     WHERE 1=1
     --  AND sofar <> totalwork         -- if you want to see active operations only
     -- show active operations first
     ORDER BY SIGN( sofar - NVL( totalwork, 0 )), last_update_time DESC
  )
  WHERE ROWNUM < 40
;
