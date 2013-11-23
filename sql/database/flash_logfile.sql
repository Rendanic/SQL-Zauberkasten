--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: flash_logfile.sql 60 2010-03-13 11:20:37Z tbr $
--
-- Information from gV$FLASHBACK_DATABASE_LOGFILE

set lines 140 pages 100 trimspool on

column dd_hhmiss format a9
column sequence# format 999999
column thread# format 99
column name format a80
column log# format 9999999
column MB format 9999

select log#
      ,to_char(first_time,'dd hh24:mi:ss') dd_hhmiss
--      ,name
      ,sequence#
      ,trunc(bytes/1024/1024) MB
      ,first_change#
      ,thread#
      ,first_change#
from gV$FLASHBACK_DATABASE_LOGFILE
order by first_time ;
