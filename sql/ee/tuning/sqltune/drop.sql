PROMPT -- Parameter 1: tuning task name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: drop.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Drops a tuning task
--
-- Metalink Note: 262687.1 How to use the Sql Tuning Advisor.
set serverout on
set verify off

begin
  dbms_sqltune.DROP_TUNING_TASK (task_name => '&1');
end;
/


