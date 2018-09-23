--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 23.09.2018
--
-- Status for observers
--
-- The information is only calid on the PRIMARY Host!

set lines 200 pages 20

column name format a30
column host  format a40
column master  format a6
column pt format a3
column pt format a3

select fo.name
     , fo.registered
     , fo.host
     , fo.ismaster master
     , fo.pinging_primary pp
     , fo.pinging_target  pt
from V$FS_FAILOVER_OBSERVERS fo
join v$database vd on vd.database_role = 'PRIMARY'
order by 1,3;
