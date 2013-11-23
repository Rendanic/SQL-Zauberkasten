PROMPT Parameter 1: REGEXP fuer Hosts
PRONPT Parameter 2: Spoolfile
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: login.sql 54 2010-03-13 08:39:25Z tbr $
--
-- Generates a HTML-Report for TBS-Infos from a host
--
set markup html on entmap off preformat off
set pages 2000
set feedback off
set verify off


spool &2..html
select target_name
     , filesystem
     , round(sizeb/1024/1024/1024,1)sizeGB
     , round(usedb/1024/1024/1024,1) usedGB
     , round(freeb/1024/1024/1024,1) freeGB
     , round(100*round(usedb/1024/1024/1024,1)/round(sizeb/1024/1024/1024,1),2) used_pct
     , mountpoint
from sysman.MGMT$STORAGE_REPORT_LOCALFS
where (mountpoint like '%oradata%' or mountpoint like '%flashback%')
and regexp_like(target_name, '&1')
order by 1,mountpoint
;

select host_name, target_name,tablespace_name
, sum(tbsGB) tbsSumGB
, sum(tbsusedGB) tbsusedGB
, round(100*sum(tbsusedGB)/sum((tbsGB+0.0000000000001)),1) used_pct
from (
select mt.host_name, mt.target_name, tablespace_name
, round(mt.tablespace_size/1024/1024/1024,3) tbsGB
, round(decode(contents,'TEMPORARY',mt.tablespace_size,mt.tablespace_used_size)/1024/1024/1024,3) tbsusedGB
from sysman.MGMT$DB_TABLESPACES mt
where target_type='oracle_database'
and regexp_like(host_name,'&1')
)
group by grouping sets ((host_name, target_name,tablespace_name),(host_name,target_name))
order by host_name, target_name, tablespace_name nulls last
;

spool off
set markup html off
set verify on feedba on
