--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 0.1
-- Date: 19.12.2014
--
-- Display Autotask History
--
set lines 140
column JOB_NAME format a30
column JOB_STATUS format A15
column JOB_START format a17
column JOB_DURATION format a20
--column NEXT_TRY_DATE format a17

select 
JOB_NAME
 ,JOB_STATUS
 ,to_char(JOB_START_TIME, 'dd.mm.yy hh24:mi:ss') JOB_START
 ,JOB_DURATION
from 
(
 select *
 from DBA_AUTOTASK_JOB_HISTORY
 order by JOB_START_TIME desc
)
where rownum < 30
order by JOB_START_TIME
;
