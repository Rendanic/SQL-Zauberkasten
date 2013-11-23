--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pxprocessstat.sql 96 2010-03-24 05:52:08Z tbr $
--
-- statistical information about parallel query processes

set lines 120
set pages 100
set trimspool on

column STATISTIC format a30
column VALUE format 999999999999
select * from V$PX_PROCESS_SYSSTAT;
