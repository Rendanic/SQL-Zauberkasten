--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: librarycache.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display statistics from v$librarycache
--
-- http://download.oracle.com/oowsf2005/003wp.pdf
--
select namespace
      ,pins
      ,pins-pinhits
      ,reloads
      ,invalidations
      ,100*(reloads-invalidations)/(pins-pinhits) "%Reloads"
from v$librarycache
where pins > 0
order by namespace;
