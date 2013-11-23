--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: cancel_exec.sql 558 2012-11-23 06:23:58Z tbr $
--
-- Cancel a running operation in Session
--
set verify off

begin
  dbms_system.set_ev(&1,&2,10237,1,'');
  dbms_lock.sleep(1);
  dbms_system.set_ev(&1,&2,10237,0,'');
end;
/
