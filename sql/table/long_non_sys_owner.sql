--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: long_non_sys_owner.sql 249 2010-11-23 20:20:00Z tbr $
--
-- Displays Non-Sys-Owner with %LONG%-Columns
--
set lines 120
set pages 100
column owner format a30

select distinct owner
from dba_tab_columns
where data_type like '%LONG%'
and owner not in ('SYS','SYSTEM','OUTLN','EXFSYS','SYSMAN','WMSYS')
order by 1
;