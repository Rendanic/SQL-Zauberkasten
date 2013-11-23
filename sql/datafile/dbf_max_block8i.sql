--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dbf_max_block8i.sql 66 2010-03-15 05:20:34Z tbr $
--
-- Displays highest block in Datafile. How small can a datafile be changed?
-- compatible for Oracle 8i
--
set lines 120
set pages 200
column file_name format a50
column tablespace_name format a25
column mb format 999999
column mb2 format 999999

select de.tablespace_name
      ,ddf.file_name
      ,max((de.block_id+de.blocks)) maxblock
      ,ddf.blocks blocks
  from dba_data_files ddf
     , dba_extents de
 where de.tablespace_name like '%&1%'
   and ddf.file_id = de.file_id
group by de.tablespace_name, ddf.file_name,ddf.blocks
order by de.tablespace_name, ddf.file_name
;

