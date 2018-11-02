--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Displays information for Tempfile (dbfi_temp = DataBase File Information)
--
-- Version: 2
-- Date: 02.11.2018
set pages 300
set lines 150

column file_name format a60
column tablespace_name format a20
column mb format 99999999
column os format a6
column id format 999
column status format a11

select ddf.TABLESPACE_NAME
      ,ddf.bytes/1024/1024 MB
      ,ddf.AUTOEXTENSIBLE auto
      ,ddf.status
      ,ddf.file_id id
--      ,ddf.online_status os
      ,ddf.file_name
  from dba_temp_files ddf
 order by tablespace_name, file_name;

