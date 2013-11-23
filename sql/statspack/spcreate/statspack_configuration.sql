--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: statspack_configuration.sql 50 2010-03-12 05:39:24Z tbr $
--
-- Configurationfile for statspack_create.sql
--

-- Password for perfstat-User (Can be changed after installation.)
define perfstat_password=statspack

-- Tablespaceparameter for perfstat-User
define temporary_tablespace=temp
define default_tablespace=perfstat

-- Purgetime in days for statspack Snapshots
define purgedates=35

-- Interval for Snapshots in dbms_job
define snapinterval='trunc(SYSDATE+1/24,''HH'')'

-- Snaplevel for Snapshots
-- 5 = Default
-- 6 = sql plans + plan usage
-- 7 = segment statistics
--10 = parent and child latches
define snaplevel=7