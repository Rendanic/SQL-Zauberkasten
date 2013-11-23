--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dbf_minsize.sql 66 2010-03-15 05:20:34Z tbr $
--
-- generates SQL for min resize of all datafiles
--
set lines 120
set pages 200
column file_name format a150

select 'alter database datafile '''
      ||file_name||''' resize '
      ||to_char(trunc((max((de.block_id+de.blocks)*dt.block_size)/1024/1024)+5 ))
      ||'m;'
  from dba_data_files ddf
  left outer join dba_extents de on ddf.tablespace_name = de.tablespace_name
                     and ddf.file_id = de.file_id
  join dba_tablespaces dt on dt.tablespace_name = de.tablespace_name
 where de.tablespace_name like '%&1%'
group by dt.tablespace_name, ddf.file_name,ddf.bytes/1024/1024
order by dt.tablespace_name, ddf.file_name
;

