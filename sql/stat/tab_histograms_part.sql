--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tab_histograms_part.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Display Histograms of a table Partition column
--
-- Parameter 1: Owner
-- Parameter 2: Table-Name
-- Parameter 3: Partition-Name
-- Parameter 4: Column-Name
--
-- Metalink Note 68992.1 Predicate Selectivity
-- endpoint_actual_value ist gefuellt, wenn endpoint_value nicht eindeutig (meist bei Datumswerten)
--
-- folgendes gilt fuer DBA_PART_HISTOGRAMS
-- Wenn Distinct Values = Anzahl Buckets
-- => Bucket number = Anzahl Wert fuer enpoint_value
--
prompt parameter 1: owner
prompt parameter 2: table_name
prompt parameter 3: partition_name
prompt parameter 4: column_name
set lines 140
set pages 100
column owner format a20
column table_name format a30
column column_name format a30
column endpoint_actual_value format a20
select table_name
      ,partition_name
      ,column_name
      ,endpoint_value
      ,bucket_number en
      ,endpoint_actual_value
from DBA_PART_HISTOGRAMS
where owner like '&1'
  and table_name like '&2'
  and partition_name like '&3'
  and column_name like '&4'
order by 1,2,3,4
;

