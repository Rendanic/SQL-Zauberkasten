--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: subpool_cnt.sql 10 2008-11-11 10:25:06Z oracle $
--
-- get number of subpools from shared_pool
--
select a.ksppinm "Parameter",
b.ksppstvl "Session Value",
c.ksppstvl "Instance Value"
from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c
where a.indx = b.indx and a.indx = c.indx
and a.ksppinm like '%kghdsidx%';

