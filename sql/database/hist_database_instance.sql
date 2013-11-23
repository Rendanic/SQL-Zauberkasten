--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: hist_database_instance.sql 22 2010-03-10 04:34:49Z tbr $
--
-- Diesplay historical information from dba_hist_database_instance
--


set lines 120 pages 100

column dbid format 9999999999
column DB_NAME format a9
column INAME format a9
column HOST_NAME format a25
column VERSION format a12
column "Id"  format 99
column start_time format a17

select DB_NAME
      ,INSTANCE_NAME iname
      ,HOST_NAME
      ,to_char(STARTUP_TIME, 'dd.mm.yy HH24:mi:ss') start_time
      ,VERSION
      ,DBID
      ,INSTANCE_NUMBER "Id"
from (
 select *
from DBA_HIST_DATABASE_INSTANCE
order by STARTUP_TIME desc
)
where rownum < 11
order by STARTUP_TIME;

