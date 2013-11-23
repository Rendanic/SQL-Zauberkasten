--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: disable.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Disables a sql-profile
---
set verify off

BEGIN
  DBMS_SQLTUNE.ALTER_SQL_PROFILE(
     name    => '&task_name',
     attribute_name  => 'STATUS', 
     value           => 'DISABLED');
END;
/

