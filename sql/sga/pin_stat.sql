--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pin_stat.sql 10 2008-11-11 10:25:06Z oracle $
--
-- statistical information for pinned objects
--
--column owner format a30
column used format a7
column cnt format 99999
column sizekB format 99999
set pages 200
set lines 120
set trimspool on

select owner
      , case executions when 0 then 'notused' else 'used' end used
      , sum(SHARABLE_MEM)/1024 sizekB
      , count(1)
from V$DB_OBJECT_CACHE a
where kept = 'YES'
group by grouping sets((owner, case executions when 0 then 'notused' else 'used' end),(case executions when 0 then 'notused' else 'used' end),())
order by owner, 2
;

