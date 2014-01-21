--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date 21.01.2014
-- Version 0.1
--
-- Displays information for next extend for each Datafile 
--
set pages 300
set lines 150

column file_name format a60
column tablespace_name format a20
column mb format 99999
column os format a6
column id format 999
column incrblk format 999999

select ddf.TABLESPACE_NAME
      ,ddf.bytes/1024/1024 MB
      ,ddf.AUTOEXTENSIBLE auto
      ,ddf.INCREMENT_BY incrblk
      ,ddf.file_id id
      ,ddf.file_name
  from dba_data_files ddf
 order by tablespace_name, file_name;


