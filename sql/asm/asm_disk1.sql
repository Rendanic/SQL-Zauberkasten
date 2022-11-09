--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- list information for all asm-disks
--
-- Version: 1
-- Date: 09.11.2022

set lines 120 pages 100

column name format a20
column header_status format a15
column path format a50
column label format a20
column gn format 999
column dn format 999

SELECT group_number gn
     , disk_number dn
     , name
     , label
     , header_status
     , path 
FROM V$ASM_DISK
order by 1,2
;
