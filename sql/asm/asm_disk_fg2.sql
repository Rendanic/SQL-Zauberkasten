--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: asm_disk1.sql 167 2010-08-13 04:21:32Z tbr $
--
-- list information for all asm-disks
--

set lines 120 pages 100

column path format a40
column header_status format a11
column format mount_status a11
column format mode_status a11

column path format a50
column label format a20
column gn format 999
column dn format 999

SELECT group_number gn
     , disk_number dn
     , FAILGROUP
     , header_status
     , mount_status
     , mode_status
     , path
FROM V$ASM_DISK
order by 1,failgroup,path
;
