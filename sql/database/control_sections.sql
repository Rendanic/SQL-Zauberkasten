--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- 
-- Date: 03.12.2015
--
-- Details about Controlfile sections
-- 
--



column type format a40
column RECORD_SIZE format 999999999
column RECORDS_TOTALA format 999999999
column RECORDS_USED format 999999999

SET LINESIZE 125

SELECT type
      ,sum(RECORD_SIZE)
      ,sum(RECORDS_TOTAL)
      ,sum(RECORDS_USED)
FROM V$CONTROLFILE_RECORD_SECTION
group by grouping sets ((type), ())
order by 1;



