--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: status_all_dbs.sql 424 2012-05-18 14:55:06Z tbr $
--
-- displays backupstate for all DBs in RMAN-Repository
--

set lines 120
set pages 250

column db_key format 9999999999
column dbinc_key format 9999999999
column dbid format 9999999999
column reset_time format a20
column BACKUPLEVEL format a12

PROMPT Full and Level 0 Backups
with allbackups as
(SELECT
      a.name DB,
      dbid,
      DECODE(b.bck_type,'D',MAX(b.completion_time),'I', MAX(b.completion_time),'L', MAX(b.completion_time))
      backuptime,
	  DECODE(b.bck_type,'L','A','D',nvl(to_char(b.incr_level),'F')) backuplevel,
	  bck_type
    FROM
      rc_database a,
      bs b
    WHERE
      a.db_key        =b.db_key
    AND b.bck_type   IS NOT NULL
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_controlfile
        WHERE
          AUTOBACKUP_DATE      IS NOT NULL
        OR AUTOBACKUP_SEQUENCE IS NOT NULL
      )
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_spfile
      )
    GROUP BY
      a.name,
      dbid,
      b.bck_type,
	  b.incr_level)
SELECT
  DB NAME,
  dbid,
  TO_CHAR(MAX(backuptime),'DD.MM.YYYY HH24:MI') Backuptime,
  backuplevel
FROM allbackups
where backuplevel in ('F','0')
GROUP BY
  db,
  dbid,
  backuplevel
ORDER BY
  least(to_date(backuptime,'DD.MM.YYYY HH24:MI')); 

PROMPT Level 1 Backups
  
with allbackups as
(SELECT
      a.name DB,
      dbid,
      DECODE(b.bck_type,'D',MAX(b.completion_time),'I', MAX(b.completion_time),'L', MAX(b.completion_time))
      backuptime,
	  DECODE(b.bck_type,'L','A','D',nvl(to_char(b.incr_level),'F')) backuplevel,
	  bck_type
    FROM
      rc_database a,
      bs b
    WHERE
      a.db_key        =b.db_key
    AND b.bck_type   IS NOT NULL
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_controlfile
        WHERE
          AUTOBACKUP_DATE      IS NOT NULL
        OR AUTOBACKUP_SEQUENCE IS NOT NULL
      )
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_spfile
      )
    GROUP BY
      a.name,
      dbid,
      b.bck_type,
	  b.incr_level)
SELECT
  DB NAME,
  dbid,
  TO_CHAR(MAX(backuptime),'DD.MM.YYYY HH24:MI') Backuptime,
  backuplevel
FROM allbackups
where backuplevel in ('1')
GROUP BY
  db,
  dbid,
  backuplevel
ORDER BY
  least(to_date(backuptime,'DD.MM.YYYY HH24:MI')); 

 
PROMPT Archivelog Backups 
  
with allbackups as
(SELECT
      a.name DB,
      dbid,
      DECODE(b.bck_type,'D',MAX(b.completion_time),'I', MAX(b.completion_time),'L', MAX(b.completion_time))
      backuptime,
	  DECODE(b.bck_type,'L','A','D',nvl(to_char(b.incr_level),'F')) backuplevel,
	  bck_type
    FROM
      rc_database a,
      bs b
    WHERE
      a.db_key        =b.db_key
    AND b.bck_type   IS NOT NULL
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_controlfile
        WHERE
          AUTOBACKUP_DATE      IS NOT NULL
        OR AUTOBACKUP_SEQUENCE IS NOT NULL
      )
    AND b.bs_key NOT IN
      (
        SELECT
          bs_key
        FROM
          rc_backup_spfile
      )
    GROUP BY
      a.name,
      dbid,
      b.bck_type,
	  b.incr_level)
SELECT
  DB NAME,
  dbid,
  TO_CHAR(MAX(backuptime),'DD.MM.YYYY HH24:MI') Backuptime,
  backuplevel
FROM allbackups
where bck_type = 'L'
GROUP BY
  db,
  dbid,
  backuplevel
ORDER BY
  least(to_date(backuptime,'DD.MM.YYYY HH24:MI')); 
