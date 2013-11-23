--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: start_all.sql 10 2008-11-11 10:25:06Z oracle $
--
--Note:459189.1 Subject: 	How to stop all dbms_scheduler jobs
Exec dbms_scheduler.set_scheduler_attribute('SCHEDULER_DISABLED','FALSE');

