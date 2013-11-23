--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: fill_stat_tab.sql 10 2008-11-11 10:25:06Z oracle $
--
-- export schema statistics, create destination table before
--
-- Parameter 1. Owner for Statistics and Table
-- Parameter 2: Tablename

rem Note:117203.1 Subject: 	How to Use DBMS_STATS to Move Statistics to a Different Database

exec dbms_stats.create_stat_table('&1','&2');
exec dbms_stats.EXPORT_SCHEMA_STATS('&1', '&2')
