--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Datafile information with con_id
--
-- Version: 1
-- Date: 18.12.2015
--
set pages 300
set lines 150

column file_name format a60
column tablespace_name format a20
column mb format 99999
column os format a6
column id format 999
column cdb format 999
column status format a11

select ddf.con_id cdb
      ,ddf.TABLESPACE_NAME
      ,ddf.bytes/1024/1024 MB
      ,ddf.AUTOEXTENSIBLE auto
      ,ddf.status
      ,ddf.file_id id
      ,ddf.file_name
  from cdb_data_files ddf
 order by ddf.con_id, tablespace_name, file_name;

