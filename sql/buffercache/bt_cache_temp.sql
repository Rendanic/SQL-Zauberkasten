--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 19.10.2018
--
-- Information from v$bt_scan_obj_temp
--


set lines 125 pages 200
column owner format a25
column object_name format a25
column POLICY format a15
column blocks format 999999999
column CACHED_IN_MEM format 999999999999

select ao.owner
      ,nvl(ao.object_name, 'wrong pdb!') object_name
      ,a.SIZE_IN_BLKS blocks
      ,a.POLICY
      ,a.CACHED_IN_MEM
from V$BT_SCAN_OBJ_TEMPS a
left outer join all_objects ao on ao.DATA_OBJECT_ID = a.DATAOBJ#
order by 1,2;
