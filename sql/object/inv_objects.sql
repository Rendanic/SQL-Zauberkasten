--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: inv_objects.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays invalid objects in the database
--
set pages 200
set lines 200
column owner format a30
column object_type format a20
column object_name format a30
column cnt format 99999

select owner
     , object_type
     , object_name
     , count(1) cnt
  from dba_objects
 where status != 'VALID'
 group by grouping sets((owner, object_type,object_name),(owner),())
 order by owner nulls last, object_type nulls last, object_name 
;

