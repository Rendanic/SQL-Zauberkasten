--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: stat_operation.sql 10 2008-11-11 10:25:06Z oracle $
--
-- display optstat operations from dba_optstat_operations
--
set pages 1000
set lines 120
column OPERATION format a40

select operation, to_char(start_time, 'dd.mm.yy hh24:mi') startt, to_char(end_time, 'dd.mm.yy hh24:mi') endt
  from (select operation, start_time, end_time
          from DBA_OPTSTAT_OPERATIONS 
      order by start_time desc
       )
where rownum < 20
order by start_time
;

