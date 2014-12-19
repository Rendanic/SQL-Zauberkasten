---
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 0.1
-- Date: 19.12.2014
--
-- Disable the Segment Space Advisor in Oracle 11.1 and 11.2
-- DBMS_AUTO_TASK_ADMIN.DISABLE still shows the client_name enabled in DBA_AUTOTASK_CLIENT view (Doc ID 1565768.1)

select * 
  from DBA_AUTOTASK_WINDOW_CLIENTS;

begin
 DBMS_AUTO_TASK_ADMIN.DISABLE('AUTO SPACE ADVISOR', NULL, NULL);
end;
/

select * 
  from DBA_AUTOTASK_WINDOW_CLIENTS;
