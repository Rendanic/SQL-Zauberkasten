prompt 1. Parameter: Tage
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: check_old_rman_dbs.sql 222 2010-11-01 21:48:49Z tbr $
--
-- displays database with backups older then n days
--
column db_key format 9999999999
column dbinc_key format 9999999999
column dbid format 9999999999
column name format a10
column reset_time format a20
select rc.db_key
      ,rc.dbid
      ,rc.dbinc_key
      ,rc.name
      ,to_char(rc.resetlogs_time,'dd.mm.yyyy hh24:mi') reset_time
from rc_database rc
where not exists(select 1 
                 from rc_backup_piece rbp
                 where rc.DB_KEY = rbp.db_key
                 and   rc.DBID   = rbp.DB_ID
                 and   rbp.START_TIME > sysdate - &1
                );

