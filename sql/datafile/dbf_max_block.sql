--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dbf_max_block.sql 66 2010-03-15 05:20:34Z tbr $
--
-- Displays highest block in Datafile. How small can a datafile be changed?
--
set lines 120
set pages 200
column file_name format a50
column tablespace_name format a25
column mb format 999999
column mb2 format 999999

select dt.tablespace_name
      ,ddf.file_name
      ,max((de.block_id+de.blocks)*dt.block_size)/1024/1024 MB
      ,ddf.bytes/1024/1024 MB2
  from dba_data_files ddf
  join dba_extents de on ddf.tablespace_name = de.tablespace_name
                     and ddf.file_id = de.file_id
  join dba_tablespaces dt on dt.tablespace_name = de.tablespace_name
 where de.tablespace_name like '%&1%'
group by dt.tablespace_name, ddf.file_name,ddf.bytes/1024/1024
order by dt.tablespace_name, ddf.file_name
;

