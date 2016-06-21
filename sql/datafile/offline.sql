--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Displays Offline Datafiles
--
-- Date: 16.06.2016
--
set pages 300
set lines 150

column file_name format a60

select file#
      ,status
      ,enabled
      ,CHECKPOINT_TIME
      ,name file_name
from v$datafile
where STATUS = 'OFFLINE'
order by file#;

