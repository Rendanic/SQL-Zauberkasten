--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_histograms2.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display Histograms of a table column
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
-- Parameter 3: Column-Name
--
set lines 140
set pages 100

column owner format a20
column table_name format a30
column column_name format a30
column endpoint_actual_value format a20

select owner
      ,table_name
      ,column_name
      ,endpoint_number en
      ,endpoint_value
      ,endpoint_actual_value
from DBA_TAB_HISTOGRAMS
where owner like '&1'
  and table_name like '&2'
order by 1,2,3,4
;

