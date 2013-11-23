--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_histograms.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display Histograms of a table column
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
-- Parameter 3: Column-Name
--
-- Metalink Note 68992.1 Predicate Selectivity
-- endpoint_actual_value ist gefuellt, wenn endpoint_value nicht eindeutig (meist bei Datumswerten)
--
-- folgendes gilt fuer DBA_PART_HISTOGRAMS
-- Wenn Distinct Values = Anzahl Buckets
-- => Bucket number = Anzahl Wert fuer enpoint_value
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
  and column_name like '&3'
order by 1,2,3,4
;

