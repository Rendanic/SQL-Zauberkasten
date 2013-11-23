prompt -- Parameter task_name
prompt -- Parameter Description
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: accept.sql 30 2010-01-12 20:58:11Z oracle $
--
-- accept a sql-profile for a tuning task
set verify off

begin
  DBMS_SQLTUNE.ACCEPT_SQL_PROFILE (
    task_name    => '&task_name'
   ,name         => '&description'
   );
end;
/

