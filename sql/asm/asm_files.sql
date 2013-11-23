--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: asm_files.sql 164 2010-08-02 19:32:40Z tbr $
--
-- list files from ASM
--
set lines 120 pages 100 
column gnum format 999.999.999
column filnum format 999.999.999
column fname format a95

SELECT gnum
     , filnum
	 , concat('+'||gname,sys_connect_by_path(aname, '/')) fname
FROM (SELECT g.name gname
           , a.parent_index pindex
		   , a.name aname
		   , a.reference_index rindex
		   , a.group_number gnum
		   ,a.file_number filnum
      FROM v$asm_alias a
	      ,v$asm_diskgroup g
      WHERE a.group_number = g.group_number
	 )
START WITH (mod(pindex, power(2, 24))) = 0
CONNECT BY PRIOR rindex = pindex; 