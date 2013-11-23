--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: list_prof.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Displays SQL_Profiles from Data-Dictionary
--
-- Metalink Note: 271196.1 Automatic SQL Tuning - SQL Profiles
--
set verify off

column name format a30
column category format a10
column sql_text format a50

select name
      ,category
      , created
      , status
      , sql_text
from DBA_SQL_PROFILES
;

