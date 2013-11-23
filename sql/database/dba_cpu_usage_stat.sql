--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dba_cpu_usage_stat.sql 465 2012-09-06 11:19:11Z tbr $
--
-- Displays information from DBA_CPU_USAGE_STATISTICS
--
set lines 80
set pages 100

column dbid format 9999999999
column zeitpunkt format a20
column VERSION format a17
column CPU_COUNT format 999
column Cores format 99
column Sockets format 99

select dbid
      ,to_char(TIMESTAMP, 'dd.mm.yy HH24:mi:ss') zeitpunkt
--      ,VERSION
      ,CPU_COUNT
      ,CPU_CORE_COUNT Cores
      ,CPU_SOCKET_COUNT Sockets
from DBA_CPU_USAGE_STATISTICS
order by TIMESTAMP;

