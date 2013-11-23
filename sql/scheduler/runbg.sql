--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: runbg.sql 10 2008-11-11 10:25:06Z oracle $
--
begin
 dbms_scheduler.run_job('&1'||'.'||'&2',false);
end;
/

