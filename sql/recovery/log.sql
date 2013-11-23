--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: log.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Information from gv$recovery_log

set lines 120
set pages 100
set trimpspool on

column thread format 99
column sequence# format 999999
column zeit format a12
column archive_name format a80

select thread#
       ,sequence#
       ,to_char(time,'dd HH24:mi:ss') zeit
       ,archive_name
from GV$RECOVERY_LOG
order by time,thread#; 
