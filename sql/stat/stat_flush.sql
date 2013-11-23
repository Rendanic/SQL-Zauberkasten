--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: stat_flush.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Flush statistic monitoring information
--
prompt DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; 
begin
   DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; 
end;
/

