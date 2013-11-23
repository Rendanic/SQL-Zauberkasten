PROMPT Parameter 1: DB-ID
PROMPT Parameter 2: Tablespace-Name
--
-- Historical information for tablespaces
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awrrpt_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--

set echo off heading on underline on;
set verify off

column snap_id format 999999999
column rtime format a20
column tbs_size format 999999999
column tbs_max format 999999999
column tbs_used format 999999999
column Tablespace format a30

select b.snap_id
      ,b.rtime
      ,a.tsname Tablespace
      ,round(b.tablespace_size/1024) tbs_size
      ,round(b.tablespace_maxsize/1024) tbs_max
      ,round(b.tablespace_usedsize/1024) tbs_used
from DBA_HIST_TABLESPACE_STAT a
join DBA_HIST_TBSPC_SPACE_USAGE b on a.snap_id = b.snap_id 
                                 and a.ts# = b.TABLESPACE_ID
                                 and a.dbid = b.dbid
where a.tsname like '&2'
  and a.dbid = &1
order by a.snap_id 
;
