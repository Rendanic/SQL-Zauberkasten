--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sistat.sql 233 2010-11-13 20:42:23Z tbr $
--
-- some sesstat information for given SID
--
-- Parameter 1: SessionID
--

set pages 100
set lines 120
column name format a70
column value format 999,999,999,999
select round((se.value)/1,3) value,
       n.name
from v$sesstat se,
     v$statname n
where n.statistic# = se.statistic#
and   (n.name in ('session pga memory','session pga memory max',
                 'session uga memory','session uga memory max')
      or n.name like '%consistent%'
      or n.name like '%physical read%'
      or n.name like '%physical write%'
      or n.name like '%parse%'
      or n.name like '%recovery%'
      or n.name like '%redo%'
      or n.name like 'table%'
      or n.name like 'user%'
      or n.name like 'undo%'
      or n.name like 'CPU %'
      or n.name like '%commit%'
      or n.name like 'lob %'
      )
and se.sid = &1
and se.value != 0
order by name
/

