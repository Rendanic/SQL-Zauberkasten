--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- display advanced plan for last explain in current session
--
-- Date: 04.06.2016
--
set pages 2000
set lines 200
column PLAN_TABLE_OUTPUT format a200

select * 
from table(dbms_xplan.DISPLAY_CURSOR(null,null,'ADVANCED'))
;

