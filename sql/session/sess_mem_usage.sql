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
set verify off

COLUMN category      HEADING "Category"
COLUMN allocated     HEADING "Allocated bytes"
COLUMN used          HEADING "Used bytes"
COLUMN max_allocated HEADING "Max allocated bytes"

SELECT pid, category, allocated, used, max_allocated
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
