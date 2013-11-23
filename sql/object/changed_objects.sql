--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: changed_objects.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Displays changed objects in last n days
--
prompt Parameter 1: Object-Owner
prompt Parameter 2: number of days for (sysdate-<Parameter 2>)

set pages 200
set lines 120
set verify off

column owner format a30
column object_type format a20
column object_name format a30
column last_ddl format a14
column cnt format 9999

select owner
     , object_type
     , object_name
     , to_char(last_ddl_time, 'dd.mm.yy hh24:MI') last_ddl
     , count(1) cnt
  from dba_objects
 where last_ddl_time > sysdate - &2
   and owner like ('&1')
 group by grouping sets((owner, object_type,object_name,last_ddl_time),(owner),())
 order by owner nulls last, object_type nulls last, object_name 
;

