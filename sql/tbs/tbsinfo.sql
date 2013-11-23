--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tbsinfo.sql 10 2008-11-11 10:25:06Z oracle $
--
-- tablespace details (no size information!)
--
set lines 130
set pages 1000

column tablespace_name format a25
column bs format 99999
column status format a8
column contents format a10
column EXTENT_MANAGEMENT format a12
column ALLOCATION_TYPE format a7
column minext_kb format 999999999
column ssm format a8


select tablespace_name
      ,block_size bs
      ,status
      ,contents
      ,EXTENT_MANAGEMENT 
      ,ALLOCATION_TYPE
      ,MIN_EXTLEN/1024 minext_kb
      ,SEGMENT_SPACE_MANAGEMENT ssm
  from dba_tablespaces
 order by tablespace_name
;

