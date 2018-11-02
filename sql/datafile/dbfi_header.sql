--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 2
-- Date: 02.11.2018
--
-- Details from v$datafile_header
--
select file#,
       status,
       resetlogs_change#,
       resetlogs_time,
       checkpoint_change#,
       to_char(checkpoint_time, 'DD-MON-YYYY HH24:MI:SS') as checkpoint_time
from v$datafile_header
order by status, checkpoint_change#, file#;