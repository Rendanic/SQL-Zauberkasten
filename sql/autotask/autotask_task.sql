--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 0.1
-- Date: 19.12.2014
--
-- Display Autotasks

column TASK_NAME format a20
column LAST_GOOD_DATE a17
column NEXT_TRY_DATE a17

select OPERATION_NAME
,STATUS
,to_char(LAST_GOOD_DATE, 'dd.mm.yy hh24:mi:ss') last_good_date
,to_char(NEXT_TRY_DATE, 'dd.mm.yy hh24:mi:ss') NEXT_TRY_DATE
from DBA_AUTOTASK_TASK
order by 1
;
