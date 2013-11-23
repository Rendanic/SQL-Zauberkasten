--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: lock_schema_stat.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Lock Statistics for a schema
--
-- Parameter 1: Schemaname
begin
   dbms_stats.lock_schema_stats('&1');
end;
/

