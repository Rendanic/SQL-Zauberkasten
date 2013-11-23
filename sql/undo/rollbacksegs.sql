--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: rollbacksegs.sql 258 2010-11-29 21:31:09Z tbr $
--
-- Information for all Rollback-Segments
--
set lines 120 pages 30

column segment_name format a25
column s_id format 999
column status format a10
column tablespace_name format a15
column IID format a3

select segment_name 
,segment_id s_id
,status
,tablespace_name
,instance_num IID
from dba_rollback_segs
order by status, segment_id;

