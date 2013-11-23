--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: mview_info.sql 86 2010-03-23 20:17:37Z tbr $
--
-- Display information from gicen MVIEW
--
prompt parameter 1: MVIEW-Owner
prompt Parameter 2: MVIEW-Name

set lines 200
set pages 200
set verify off

column table_name format a30
column f_blk format 999999
column owner format a20
column tablespace_name format a20
column blocks format 9999999
column rowl format 999999
column pfr format 99

select owner
      ,mview_name
      ,FAST_REFRESHABLE fr
      ,LAST_REFRESH_TYPE lr
      ,LAST_REFRESH_DATE
      ,COMPILE_STATE
  from dba_mviews
where owner like ('&1')
  and mview_name like ('&2')
order by owner, mview_name
;

