--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 17.12.2017
--
--  Load Profile from Statspack-Schema
--
-- This SQL is compatible against PostgreSQL to learn
-- using SQL for Oracle and PostgreSQL at the same time.


set pages 100
set lines 125
column instance_name format a12
column startup_time  format a12
column snapshot_time format a15
column log_reads format 99999999
column blk_changes format 9999999
column phys_reads format 9999999
column phys_writes format 9999999
column user_calls format 99999
column commits format 99999.9
column rollbacks format 9999.9

SELECT
    instance_name,
    TO_CHAR(startup_time,'dd.mm hh24:mi') startup_time,
    TO_CHAR(snap_time,'dd.mm hh24:mi:ss') snapshot_time,
    round(
        CASE snapints
            WHEN 0   THEN logical_reads
            ELSE(logical_reads / snapints)
        END
    ) log_reads,
    round(
        CASE snapints
            WHEN 0   THEN block_changes
            ELSE(block_changes / snapints)
        END
    ) blk_changes,
    round(
        CASE snapints
            WHEN 0   THEN physical_reads
            ELSE(physical_reads / snapints)
        END
    ) phys_reads,
    round(
        CASE snapints
            WHEN 0   THEN logical_reads
            ELSE(logical_reads / snapints)
        END
    ) phys_writes,
    round(
        CASE snapints
            WHEN 0   THEN user_calls
            ELSE(user_calls / snapints)
        END
    ) user_calls,
    CASE snapints
            WHEN 0   THEN commits
            ELSE round(CAST( (commits / snapints) AS FLOAT),1)
        END
    commits,
    CASE snapints
            WHEN 0   THEN rollbacks
            ELSE round(CAST( (rollbacks / snapints) AS FLOAT),1)
        END
    rollbs
FROM
    (
        SELECT
            dbid,
            instance_name,
            instance_number,
            startup_time,
            snap_time,
            logical_reads,
            block_changes,
            physical_reads,
            physical_writes,
            user_calls,
            commits,
            rollbacks,
            ( EXTRACT(SECOND FROM snapinterval) ++EXTRACT(MINUTE FROM snapinterval) * 60 + EXTRACT(HOUR FROM snapinterval) * 3600 + EXTRACT(DAY FROM snapinterval
) * 3600 * 24 ) snapints
        FROM
            (
                SELECT
                    di.dbid,
                    di.instance_name,
                    di.instance_number,
                    ss.startup_time,
                    ss.snap_time,
                    ss.snap_id,
                    s.value - LAG(s.value,1,s.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s.name
                        ORDER BY
                            ss.snap_id
                    ) logical_reads,
                    s2.value - LAG(s2.value,1,s2.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s2.name
                        ORDER BY
                            ss.snap_id
                    ) block_changes,
                    s3.value - LAG(s3.value,1,s3.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s3.name
                        ORDER BY
                            ss.snap_id
                    ) physical_reads,
                    s4.value - LAG(s4.value,1,s4.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s4.name
                        ORDER BY
                            ss.snap_id
                    ) physical_writes,
                    s7.value - LAG(s7.value,1,s7.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s7.name
                        ORDER BY
                            ss.snap_id
                    ) user_calls,
                    s5.value - LAG(s5.value,1,s5.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s5.name
                        ORDER BY
                            ss.snap_id
                    ) commits,
                    s6.value - LAG(s6.value,1,s6.value + 1) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time,
                        s6.name
                        ORDER BY
                            ss.snap_id
                    ) rollbacks,
                    CAST(ss.snap_time AS TIMESTAMP) - CAST( (LAG(ss.snap_time,1,ss.snap_time) OVER(
                        PARTITION BY ss.dbid,
                        ss.instance_number,
                        ss.startup_time
                        ORDER BY
                            ss.snap_id
                    ) ) AS TIMESTAMP) snapinterval
                FROM
                    stats$database_instance di
                    JOIN stats$snapshot ss ON di.dbid = ss.dbid
                                              AND di.instance_number = ss.instance_number
                                              AND di.startup_time = ss.startup_time
                    JOIN stats$sysstat s ON s.dbid = ss.dbid
                                            AND s.snap_id = ss.snap_id
                    JOIN stats$sysstat s2 ON s2.dbid = ss.dbid
                                             AND s2.snap_id = ss.snap_id
                    JOIN stats$sysstat s3 ON s3.dbid = ss.dbid
                                             AND s3.snap_id = ss.snap_id
                    JOIN stats$sysstat s4 ON s4.dbid = ss.dbid
                                             AND s4.snap_id = ss.snap_id
                    JOIN stats$sysstat s5 ON s5.dbid = ss.dbid
                                             AND s5.snap_id = ss.snap_id
                    JOIN stats$sysstat s6 ON s6.dbid = ss.dbid
                                             AND s6.snap_id = ss.snap_id
                    JOIN stats$sysstat s7 ON s7.dbid = ss.dbid
                                             AND s7.snap_id = ss.snap_id
                WHERE
                    s.name = 'session logical reads'
                    AND   s2.name = 'db block changes'
                    AND   s3.name = 'physical reads'
                    AND   s4.name = 'physical writes'
                    AND   s5.name = 'user commits'
                    AND   s6.name = 'user rollbacks'
                    AND   s7.name = 'user calls'
            ) a
    ) b
ORDER BY
    snap_time,
    instance_name
;
