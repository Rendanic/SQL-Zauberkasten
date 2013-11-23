 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: apply.sql 246 2010-11-23 19:37:50Z tbr $
--
-- State Information from dba_apply
--
set lines 140
set pages 100

column QUEUE_NAME format a20
column QUEUE_OWNER format a30
column ERROR_NUMBER format 999999
column ERROR_MESSAGE format a40
column created format a10
column STATUS format a12
column applied format a7

select QUEUE_OWNER
      ,QUEUE_NAME
      ,STATUS
      ,APPLY_CAPTURED applied
--      ,ERROR_NUMBER
--      ,ERROR_MESSAGE
      ,to_char(STATUS_CHANGE_TIME, 'dd.mm.yy hh24:mi:ss') state_timest
from dba_apply
order by STATUS_CHANGE_TIME;
 
 
