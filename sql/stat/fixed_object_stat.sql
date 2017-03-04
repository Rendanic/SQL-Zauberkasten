--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Date 03.02.2017
--
-- Number of object with/without statistics and trnc(last_analyzed)
--

set lines 120 pages 100

column owner format a20
column last_analyzed format a15
column cnt format 99999

select owner
       ,to_char(trunc(LAST_ANALYZED),'dd.mm.yy') last_analyzed
       ,count(1) cnt
from dba_tab_statistics 
where OBJECT_TYPE = 'FIXED TABLE'
group by owner,trunc(LAST_ANALYZED) 
order by 1,2;

