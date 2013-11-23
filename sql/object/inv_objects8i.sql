--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: inv_objects8i.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays invalid objects in the database
-- usable from Oracle 8.0+
--

set pages 200
set lines 200
column owner format a30
column object_type format a20
column object_name format a30

select owner
     , object_type
     , object_name
  from dba_objects
 where status != 'VALID'
 order by owner, object_type nulls last, object_name 
;

