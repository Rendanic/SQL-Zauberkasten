--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pinned_objects.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display pinned objects from shared_pool
--
column owner format a30
column name format a50
column type format a30

set pages 200
set lines 120

select owner
     , name
     , type
from V$DB_OBJECT_CACHE
where kept = 'YES'
order by owner, type, name
;
