--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Get overview from v$log and v$standby_log
--
-- Date: 18.12.2014

column sequence# 99999999

select thread#, group#, bytes, sequence#, count(1), typ
from (select l.thread#, l.group#, l.bytes, l.sequence#
            ,lf.member, 'prim' typ
        from v$log l
        join v$logfile lf on lf.group# = l.group#
      union all
      select l.thread#, l.group#, l.bytes, l.sequence#
            ,lf.member, 'stdby' typ
        from v$standby_log l
        join v$logfile lf on lf.group# = l.group#)
group by thread#, group#, bytes, sequence#, typ
order by typ, thread#,group#;
