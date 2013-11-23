--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: vi.sql 37 2010-03-10 07:49:59Z tbr $
-- 
-- Displays some Instance-Information from v$instance
--
set lines 150
column host_name format a28
column "in" format 99
column iname format a10
column status format a8
column STARTUP_TIME format a15

select INSTANCE_NUMBER "in"
     , INSTANCE_NAME iname
     , HOST_NAME
     , VERSION
     , to_char(STARTUP_TIME, 'dd.mm.yy HH24:mi') STARTUP_TIME
     , STATUS
     , LOGINS
from gv$instance;

