--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: recyclebinusage.sql 248 2010-11-23 20:18:21Z tbr $
--
-- Information from recyclebin
--
set lines 100
set pages 200
column tablespace_name format a30
column used_kb format 9999999999

select ts_name tablespace_name
      ,sum(space* block_size )/1024 used_kb
from dba_recyclebin dr
join dba_tablespaces dt on dt.tablespace_name = ts_name
group by ts_name
order by 1;

