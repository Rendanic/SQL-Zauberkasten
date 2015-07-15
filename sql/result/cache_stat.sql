
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)

-- Date 15.07.2015
--
-- List statistics from the result cache
--

col gname name a30
col dbname value a40
set trimspool on lines 120 pages 100 verify off
 
SELECT inst_id
      ,id
      ,name
      ,value
from GV$RESULT_CACHE_STATISTICS
order by name;
