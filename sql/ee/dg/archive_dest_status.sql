--
-- Lennart J.
-- Version: 0.1
-- Date: 16.07.2023
--
-- Status Archive_dest
col destination format a50;
col status format a15;
col dest_name format a20;
col dest_id format 99;
col protection_mode format a30;
set lines 300;
select DEST_ID,DEST_NAME,STATUS,DESTINATION,PROTECTION_MODE,ERROR 
from v$archive_dest_status 
where status <> 'INACTIVE';
