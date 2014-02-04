--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 03.02.2014
--
-- Stop Managed Recovery for Data-Guard

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;

