--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: glatch.sql 10 2008-11-11 10:25:06Z oracle $
--
set pages 100
select *
from (select CHILD#  "cCHILD"
,      ADDR    "sADDR"
,      GETS    "sGETS"
,      MISSES  "sMISSES"
,      SLEEPS  "sSLEEPS"
from v$latch_children
where name = 'cache buffers chains'
order by 5 desc, 1, 2, 3
) 
where rownum < 40
order by 5 
;

