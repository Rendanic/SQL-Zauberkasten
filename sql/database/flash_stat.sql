--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: flash_stat.sql 60 2010-03-13 11:20:37Z tbr $
--
-- some informationen for flash-recovery area and flashback
--

set pages 1000
set lines 120

column limit format 999999
column USED_MB format 999999
column RECLAIM_MB format 999999
column NUMBER_OF_FILES format 9999

select round(SPACE_LIMIT/1024/1024) LIMIT
      ,round(SPACE_USED/1024/1024) USED_MB
      ,round(SPACE_RECLAIMABLE/1024/1024) RECLAIM_MB
      ,NUMBER_OF_FILES
  from V$RECOVERY_FILE_DEST;

column name format a50
column oldest_time format a14

select to_char(OLDEST_FLASHBACK_TIME, 'dd.mm hh24:mi:ss') oldest_time
      ,RETENTION_TARGET
      ,round(FLASHBACK_SIZE/1024/1024) size_MB
      ,round(ESTIMATED_FLASHBACK_SIZE/1024/1024) Estimated_MB 
  from v$flashback_database_log;


select *
  from V$FLASH_RECOVERY_AREA_USAGE ;

column begin_time format a11
column end_time format a11

select to_char(begin_time, 'DD.MM HH24:MI') begin_time
     , to_char(end_time, 'DD.MM HH24:MI') end_time
     , trunc(FLASHBACK_DATA/1024/1024) flashback_MB
     , trunc(DB_DATA/1024/1024) db_MB
     , trunc(REDO_DATA/1024/1024) redo_MB
     , trunc(ESTIMATED_FLASHBACK_SIZE/1024/1024) estim_MB
from v$flashback_database_stat
order by end_time
;

