--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 12.03.2015
--
-- used space from dba_segments for users
--
-- Parameter 1: Owner

set trimspool on lines 120 pages 100 numwidth 15 verify off
column username format a30
column TABLESPACE_NAME format a30
select u.USERNAME
     , s.TABLESPACE_NAME
     , sum(round(s.bytes/1024/1024,1)) used_mb
from dba_users u
join dba_segments s on s.owner = u.username
where u.username like '&1'
group by grouping sets (username, tablespace_name)
                      ,(username)
order by 1,2;


