--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: some_cursor_stats.sql 10 2008-11-11 10:25:06Z oracle $
--
-- some cursor stats from Note 62143.1
--
rem Note:62143.1 Subject: 	Understanding and Tuning the Shared Pool

prompt Finding the Library Cache hit ratio
prompt following less then 1% miss
  SELECT SUM(PINS) "EXECUTIONS",
        SUM(RELOADS) "CACHE MISSES WHILE EXECUTING"
        FROM V$LIBRARYCACHE
;

prompt Checking for high version counts:
prompt 
SELECT address, hash_value,
                version_count ,
                users_opening ,
                users_executing,
                substr(sql_text,1,40) "SQL"
          FROM v$sqlarea
         WHERE version_count > 10
;

prompt Finding statement/s which use lots of shared pool memory:

SELECT substr(sql_text,1,40) "Stmt", count(*),
                sum(sharable_mem)    "Mem",
                sum(users_opening)   "Open",
                sum(executions)      "Exec"
          FROM v$sql
         GROUP BY substr(sql_text,1,40)
        HAVING sum(sharable_mem) > 1024*1024*5
;
