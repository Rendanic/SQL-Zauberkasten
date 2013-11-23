--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awr_modify.sql 99 2010-04-01 05:47:37Z tbr $
--
-- script to modify the AWR-Settings!
-- days        => How many days is the retention time?
-- snapinterva => Interval for Snapshots
-- The missing '/' at the end is expected!
set verify on

begin 
   DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(&days * 1440 , &snapinterval_minutes); 
end;
