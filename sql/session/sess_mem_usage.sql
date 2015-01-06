--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- 
-- Date: 06.01.2015
--
-- Detail Memory Informations for a Session
--
-- How To Find Where The Memory Is Growing For A Process (Doc ID 822527.1)
--
-- Parameter 1: SessionID
--

set lines 140
set pages 100
set verify off


COLUMN category      HEADING "Category"
COLUMN allocated     HEADING "Allocated kB"
COLUMN used_kBused_kB HEADING "Used kB"
COLUMN max_alloc_kB  HEADING "Max alloc kB"

SELECT pid, category
     , round(allocated/1024) alloc_kB
     , round(used/1024) used_kB
     , round(max_allocated/1024) max_alloc_kB
FROM   v$process_memory
WHERE  pid = (SELECT pid
              FROM   v$process
              WHERE  addr = (select paddr
                             FROM   v$session
                             WHERE  sid = &1
                            )
             )
order by 4
;

