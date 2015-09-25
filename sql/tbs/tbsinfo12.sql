--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 25.09.2015
--
-- tablespace details (no size information! 12c+
--
set lines 130
set pages 1000

column  pdb    format a16      heading "PDB Name"
column tablespace_name format a25
column bs format 99999
column status format a8
column contents format a10
column EXTENT_MANAGEMENT format a12
column ALLOCATION_TYPE format a7
column minext_kb format 999999999
column ssm format a8


select nvl(b.name, 'CDB$ROOT')  pdb_name
      ,a.tablespace_name
      ,a.block_size bs
      ,a.status
      ,a.contents
      ,a.EXTENT_MANAGEMENT 
      ,a.ALLOCATION_TYPE
      ,a.MIN_EXTLEN/1024 minext_kb
      ,a.SEGMENT_SPACE_MANAGEMENT ssm
  from cdb_tablespaces a
  left outer join v$pdbs b on a.con_id = b.con_id
 order by 1, tablespace_name
;

