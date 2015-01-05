--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- 
-- Date: 06.01.2015
--
-- How To Find Where The Memory Is Growing For A Process (Doc ID 822527.1)
-- 
-- pga information for all Sessions
--



COLUMN alme     HEADING "Alloc M"      FORMAT 99999D9
COLUMN usme     HEADING "Used M"       FORMAT 99999D9
COLUMN frme     HEADING "Freeab M"     FORMAT 99999D9
COLUMN mame     HEADING "Max M"        FORMAT 99999D9
COLUMN username                        FORMAT a15
COLUMN program                         FORMAT a22
COLUMN sid                             FORMAT a5
COLUMN spid                            FORMAT a8

SET LINESIZE 125

SELECT s.username, SUBSTR(s.sid,1,5) sid, p.spid, logon_time,
       SUBSTR(s.program,1,22) program , -- s.process pid_remote,
       s.status,
       ROUND(pga_used_mem/1024/1024) usme,
       ROUND(pga_alloc_mem/1024/1024) alme,
       ROUND(pga_freeable_mem/1024/1024) frme,
       ROUND(pga_max_mem/1024/1024) mame
FROM  v$session s,v$process p
WHERE p.addr=s.paddr
ORDER BY pga_max_mem,logon_time;


