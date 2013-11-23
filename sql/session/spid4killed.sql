--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spid4killed.sql 233 2010-11-13 20:42:23Z tbr $
--
-- get process id for killes Oracle Sessions
--
-- Doc ID: 	387077.1 
-- Subject: 	How to find the process identifier (pid, spid) after the corresponding session is killed?
--
set lines 80 pages 100

column program format a40
column spid format 99999

select spid
     , program 
from v$process 
where program!= 'PSEUDO'
  and addr not in (select paddr from v$session)
  and addr not in (select paddr from v$bgprocess);
  

