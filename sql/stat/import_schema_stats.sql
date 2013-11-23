--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: imp_stat_schema.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Import schema Statistics from table
--
-- Parameter 1: Owner of statistic table
-- Parameter 2: Table-Name of statistic table

rem Note:117203.1 Subject: 	How to Use DBMS_STATS to Move Statistics to a Different Database

exec dbms_stats.import_schema_stats('&1', '&2')
