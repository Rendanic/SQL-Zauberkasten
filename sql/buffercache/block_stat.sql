--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: block_stat.sql 43 2010-03-10 20:09:55Z tbr $
--
-- Displays statistics information from the buffer cache
-- state of blocks are counted (dirty/clean etc.)
--
column status format a10
column dirty format a1
column cnt format 99999

  select
   status    ,
   dirty     ,
   count(1) cnt  
from
   v$bh
group by grouping sets ((status),(status,dirty),(dirty))
;

