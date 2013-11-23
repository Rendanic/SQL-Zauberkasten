--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: seg_big.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display biggest segments of a tablespace
--
-- Parameter 1: Tablespacename
--

column owner format a15
column tablespace_name format a20
column segment_type format a20
column segment_name format a30
column mb format 999999
column partition_name format a30

set pages 100
set lines 150

select owner
      ,tablespace_name
      ,segment_type
      ,segment_name
      ,bytes/1024/1024 MB
      ,partition_name
  from (select *
          from dba_segments
         where tablespace_name like '&1'
          order by bytes desc
       )
 where rownum < 30
order by bytes desc
;
