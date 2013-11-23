--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: details.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Displays detail information for a latch
-- 

PROMPT TCNT = Touchcount of the block
PROMPT Parameter 1: Latchaddress

set verify off 
set pages 100
set lines 120

column segment_name format a70
column extent# format 9999999
column block# format 999999999
column tcnt format 99999
column child# format 9999999


select /*+ RULE */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch tcnt,
  l.child#
from
  sys.v$latch_children  l,
  sys.x$bh  x,
  sys.dba_extents  e
where
  x.hladdr  like '&1' and
  e.file_id = x.file# and
  x.hladdr = l.addr and
  x.dbablk between e.block_id and e.block_id + e.blocks -1
  order by x.tch ;

