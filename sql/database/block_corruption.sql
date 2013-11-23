--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: block_corruption.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display Extents with Block-Corruptions
--
set lines 140
set trimspool on
set pages 100
column file# format 9999
column format format 9999999999
column blocks format 99999
column corruption_type format a9
column cor_scn format 9999999999999
column owner format a30
column segment_name format a30
column segment_type format a20

select /*+rule*/ 
       a.file#
      ,a.block#
      ,a.blocks
      ,a.CORRUPTION_CHANGE# cor_scn
      ,a.corruption_type corr_type
      ,de.owner
      ,de.segment_name
      ,de.segment_type
from v$database_block_corruption a, dba_data_files df , dba_extents de
where a.file#=df.FILE_ID
  and de.RELATIVE_FNO = df.RELATIVE_FNO
  and (a.BLOCK# between de.block_id and de.block_id+de.blocks-1
    or a.BLOCK#+a.blocks between de.block_id and de.block_id+de.blocks-1
      )
;

