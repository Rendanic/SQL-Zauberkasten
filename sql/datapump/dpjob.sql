--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dpjob.sql 67 2010-03-15 05:22:15Z tbr $
--
-- Infos about running DataPump-Jobs
--
set lines 120
set pages 100

column OWNER_NAME format a20
column JOB_NAME format a20
column OPERATION format a10
column JOB_MODE format a30
column STATE format a15
column DG format 99
column ATS format 99
column DPS format 99

select OWNER_NAME
      ,JOB_NAME
      ,OPERATION
      ,JOB_MODE
      ,STATE
      ,DEGREE DG
      ,ATTACHED_SESSIONS ATS
      ,DATAPUMP_SESSIONS DPS
  from DBA_DATAPUMP_JOBS
;

select dds.OWNER_NAME
      ,dds.JOB_NAME
      ,dds.SESSION_TYPE
      ,vs.sid
from DBA_DATAPUMP_SESSIONS dds
join v$session vs on vs.saddr=dds.saddr
;

