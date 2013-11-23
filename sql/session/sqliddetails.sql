--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sqliddetails.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Detail information for given sql_id
--
-- Parameter 1: sql_id
--
set echo off
set lines 120
set verify off

column sql_id format a13 
column buffer_gets format 99999999999
column DISK_READS format 99999999999
column cput_ms format 999999999
column sql_text format a100
column VSC format 999
column SQL_PROFILE format a20

alter session set 
select sql_text
from  V$SQLSTATS vs  
where vs.sql_id = '&1';

select vs.sql_id, vs.version_count,
    sorts
--      ,USERS_EXECUTING ue
      ,FETCHES
      ,EXECUTIONS 
      ,vs.last_active_time
from V$SQLSTATS vs 
where vs.sql_id = '&1'
;

select vs.LAST_LOAD_TIME, vs.LAST_ACTIVE_TIME, vs.FIRST_LOAD_TIME,
     vs.CONCURRENCY_WAIT_TIME cwt
      ,vs.buffer_gets, vs.DISK_READS, vs.cpu_time
      , DIRECT_WRITES, USER_IO_WAIT_TIME,executions,ROWS_PROCESSED, SQL_PROFILE
      , elapsed_time/case executions when 0 then -1 else executions end avg_time
from V$SQLAREA_PLAN_HASH vs 
where vs.sql_id = '&1'
;
