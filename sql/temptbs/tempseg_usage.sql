--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tempseg_usage.sql 240 2010-11-14 11:33:29Z tbr $
--
-- display temp segment Usage
--
set lines 120
set pages 100

column username format a30
column size_MB format 99999
select vu.username
      --,vu.user
,vu.session_num
      ,vu.tablespace
      ,round((vu.blocks*dt.block_size)/1024/1024) size_Mb
  from v$tempseg_usage vu
  left outer join dba_tablespaces dt on dt.tablespace_name = vu.tablespace
;

