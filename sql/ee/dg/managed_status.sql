--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 19.06.2018
--
-- Status from v$managed_standby

column STATUS format a13

select process
     , thread# th
	 , SEQUENCE# seq
	 , status
	 , block#
	 , blocks 
from  V$MANAGED_STANDBY
order by process, sequence#;


