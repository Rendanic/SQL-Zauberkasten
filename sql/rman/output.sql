-- Parameter 1: RECID from v$rman_output
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: output.sql 221 2010-11-01 21:33:50Z tbr $
--
-- Detail output for a rman-job
--

set pages 10000
set lines 137
 
column output format a130
column recid format 999999

select output
from V$RMAN_OUTPUT    
where RMAN_STATUS_RECID = &1
order by stamp;

