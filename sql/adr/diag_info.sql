--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: diag_info.sql 130 2010-06-25 08:16:43Z tbr $
--
-- Displays info from gv$diag_info

--
column inst_id format 99
column name format a30
column value format a70

set lines 120 pages 100

select inst_id iid
      ,name
      ,value
from gv$diag_info
order by 1,2
;

