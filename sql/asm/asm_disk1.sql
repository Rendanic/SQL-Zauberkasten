--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: asm_disk1.sql 167 2010-08-13 04:21:32Z tbr $
--
-- list information for all asm-disks
--

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
     , header_status
     , path 
FROM V$ASM_DISK
order by 1,2
;
