--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 23.09.2018
--
-- Status from v$DG_BROKER_CONFIG

set lines 200 pages 20

column DB_UNIQUE_NAME format a30
column dataguard_role format a20
column status format 999999
column BROKER format a8
column SWITCHOVER_STATUS format a20

select db.database DB_UNIQUE_NAME
     , db.dataguard_role
     , db.status 
     , vd.DATAGUARD_BROKER BROKER
     , vd.SWITCHOVER_STATUS
from  v$DG_BROKER_CONFIG db
join v$database vd on 1=1;
