--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: resize_ops_errors.sql 10 2008-11-11 10:25:06Z oracle $
--
-- resize  operations form v$sga_resize_ops with errors
--

set lines 120
set pages 200

column parameter format a18
column oper format a7

select oper_type oper
      ,parameter
      ,initial_size/1024 isize
      ,target_size/1024 tsize
      ,final_size/1024 fsize
      ,status
      ,to_char(start_time,'dd.mm HH24:MI:SS') begtime
      ,to_char(end_time,'dd.mm HH24:MI:SS') endtime
from(
select *
from V$SGA_RESIZE_OPS
where status ='ERROR'
order by start_time desc
)
where rownum<100
order by start_time
;


