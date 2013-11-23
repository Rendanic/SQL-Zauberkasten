--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: seg_info.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Detailinformation for a given Segment-Name
--
-- Parameter 1: Segment-Owner
-- Parameter 2: Segment-Name
--

set pages 100
set lines 120

column owner format a20
column segment_name format a30
column segment_type format a10
column tablespace_name format a20
column kbytes format 999,999,999
column blocks format 999,999,999,999

select owner
      ,segment_name || ' ' || partition_name segment_name
      ,segment_type
      ,tablespace_name
      ,bytes/1024 kbytes
      ,blocks
from dba_segments
where owner like '&1'
  and segment_name like '&2';
      
