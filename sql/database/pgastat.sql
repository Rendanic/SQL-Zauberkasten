--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pgastat.sql 60 2010-03-13 11:20:37Z tbr $
--
-- Note:223730.1 Subject: 	Automatic PGA Memory Managment in 9i and 10g
-- 
-- Information for workarea-Policy
--
set lines 120
set pages 50

column wert format 9,999,999,999,999
column name format a50
select name
      ,decode(unit, 'bytes', value/1024, value) wert
      ,decode(unit, 'bytes', 'kbytes', unit) unit
from v$pgastat;

SELECT LOW_OPTIMAL_SIZE/1024 low_kb,(HIGH_OPTIMAL_SIZE+1)/1024 high_kb,
       optimal_executions, onepass_executions, multipasses_executions
FROM   v$sql_workarea_histogram
WHERE  total_executions != 0
/
column OPERATION format a25 wrap
column ESIZE format 9999999
column "MAX kB" format 9999999
column PASS format 9999
column TempkB format 99999999
column "ActTimeMS" format 999999999

break on REPORT

compute sum LABEL SUM of ACT_MEM ON REPORT
compute sum LABEL SUM of "MAX kB" ON REPORT
compute sum LABEL SUM of "TempkB" ON REPORT
compute sum LABEL SUM of ESIZE ON REPORT

-- acttimt in Sekunden!
column sql_id format a13

SELECT to_number(decode(SID, 65535, NULL, SID)) sid,
       sql_id,
       operation_type OPERATION,trunc(EXPECTED_SIZE/1024) ESIZE,
       round(active_time/1000) "ActTimeMS",
       trunc(ACTUAL_MEM_USED/1024) ACT_MEM,
       trunc(MAX_MEM_USED/1024) "MAX kB",
       NUMBER_PASSES PASS, 
       trunc(TEMPSEG_SIZE/1024) "TempkB"
FROM V$SQL_WORKAREA_ACTIVE
ORDER BY sid,sql_id;


