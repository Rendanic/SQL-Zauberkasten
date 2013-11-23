PROMPT -- Parameter zeitlimit
PROMPT -- Parameter task_name
PROMPT -- Parameter sql_id
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: create_sqlid.sql 30 2010-01-12 20:58:11Z oracle $
--
-- create a tuning task for given sql_id from shared-pool
--
-- Metalink Note: 262687.1 How to use the Sql Tuning Advisor.
-- 1. Parameter tuning task descriptor
-- 2. sqlid
set serverout on
set verify off

declare
  retval    varchar2(32000);
begin
  retval :=
  DBMS_SQLTUNE.CREATE_TUNING_TASK(sql_id => '&sql_id'
                                 ,task_name=> '&&task_name'
                                 ,time_limit=> &zeitlimit
                                 );
  dbms_output.put_line('retval: ' || nvl(retval,'(null)'));
end;
/

begin
  dbms_sqltune.Execute_tuning_task (task_name => '&&task_name');
end;
/


