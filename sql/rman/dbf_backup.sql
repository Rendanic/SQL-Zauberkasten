--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.com)
--
-- display Last Backup with level for datafiles
--
-- Date: 05.03.2016
-- Version: 1

set lines 140 pages 200
column name format a70
column max_scn format 99999999999999999
column max_fuzzy_scn format 99999999999999999
column file# format 9999
column il format 99

select bd.file#
     , bd.INCREMENTAL_LEVEL IL
     , max(bd.COMPLETION_TIME) COMPLETION_TIME
     , max(bd.CHECKPOINT_CHANGE#) MAX_SCN
     , max(ABSOLUTE_FUZZY_CHANGE#) max_fuzzy_scn
     , df.name
  from v$backup_datafile bd
  join v$datafile_header dh on dh.file# = bd.file#
  join v$datafile df on dh.file# = df.file#
 where dh.status = 'ONLINE'
 group by bd.file#, bd.INCREMENTAL_LEVEL, df.name
 order by COMPLETION_TIME
;

