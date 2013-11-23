--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: obj_statistic.sql 43 2010-03-10 20:09:55Z tbr $
--
-- Displays statistics information from the buffer cache
-- only objects with more then 200 blocks in cache are listed
-- not RAC-aware! Only the data from the current instance is reported
--
column owner format a20
column object_type format a20
column objname format a30
column sobjname format a30
column status format a6
column cnt format 999999
set lines 120
set pages 100
set trimsp on

SELECT o.OBJECT_TYPE                ,
  o.owner,
  SUBSTR(o.OBJECT_NAME,1,30) objname ,
  SUBSTR(o.subobject_name,1,30) sobjname ,
  b.status                           ,
  COUNT(b.objd) cnt
FROM v$bh b,
  dba_objects o
WHERE b.objd = o.data_object_id
GROUP BY grouping sets((o.object_type,
  o.owner,
  o.object_name       ,
  o.subobject_name    ,
  b.status ))
having COUNT(b.objd) > 200
order by 6, 4 nulls last
;

