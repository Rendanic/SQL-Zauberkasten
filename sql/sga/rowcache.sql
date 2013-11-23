--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: rowcache.sql 10 2008-11-11 10:25:06Z oracle $
--
-- rowcache information from shared_pool
--
--

set lines 120
set pages 100

column parameter format a30
column gets format 9999999
column getmisses format 9999999
column num format 9999999
column usage format 99999

select parameter
      ,sum(gets)      gets
      ,sum(getmisses) getmisses
      ,sum("COUNT")   num
      ,sum(usage)     usage
from  v$rowcache
where getmisses > 0
group by parameter
order by parameter;

SELECT parameter
     , sum(gets)
     , sum(getmisses)
     , 100*sum(gets - getmisses) / sum(gets)  pct_succ_gets
     , sum(modifications)                     updates
  FROM V$ROWCACHE
 WHERE gets > 0
 GROUP BY parameter;

