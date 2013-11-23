--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spinstance.sql 55 2010-03-13 09:18:15Z tbr $
--
-- database-instance information from statspack
--

set lines 120 pages 100 echo off

column dbid format 99999999999
column iid format 99
column start_time format a17
column DB_NAME format a10
column L_SNAP format 999999
column rac format a3
column version format a15
column instance_name format a13
column host_name format a30

select dbid
      ,DB_NAME
      ,INSTANCE_NAME
      ,INSTANCE_NUMBER iid
      ,to_char(STARTUP_TIME,'dd.mm.yy hh24:mi:ss') start_time
      ,SNAP_ID L_SNAP
      ,PARALLEL rac
      ,VERSION
      ,HOST_NAME
from stats$database_instance
order by dbid,db_name,STARTUP_TIME,instance_name;
