--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Date 12.12.2014
--
-- information for all asm-disks with Failgroups 
--

set lines 120 pages 100

column name format a20
column header_status format a15
column path format a30
column label format a20
column failgroup format a20
column gn format 999
column dn format 999

SELECT group_number gn
     , disk_number dn
     , failgroup
     , name
     , header_status
     , path 
FROM V$ASM_DISK
order by 1,3,2
;
