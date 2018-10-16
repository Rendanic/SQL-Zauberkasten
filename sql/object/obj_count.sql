--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 16.10.2018
--
-- show number of object type for users
--
-- Parameter 1: Owner

set lines 120 pages 200
column owner format a30
column object_type format a30
column cnt format 999999

select owner
      ,object_type
      ,count(1) cnt
  from all_objects
 where owner like '&1'
 group by grouping sets ((owner, object_type),(owner), ())
 order by owner nulls last, object_type nulls last;