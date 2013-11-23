--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: schedulerprog.sql 10 2008-11-11 10:25:06Z oracle $
--
set lines 140
set pages 100

column owner format a20
column program_name format a20
column program_action format a60
column prg format a60
column narg format 99

select a.owner
      ,a.program_name
      ,a.program_action
      ,a.number_of_arguments narg
      ,a.enabled
from DBA_SCHEDULER_PROGRAMS a
order by 1,2;
