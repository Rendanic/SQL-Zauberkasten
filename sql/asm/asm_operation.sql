--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date: 01.02.2016
--
-- Display current running ASM Operations

column name format a20
column OPER format a5
column POWER format 9999
column ACTUAL format 9999
column SOFAR format 9999999
column EST_RATE format 99999
column EST_MIN format 9999
column POWER format 9999

select dg.name
      ,do.OPERATION OPER
      ,do.staTE
      ,do.POWER
      ,do.ACTUAL
      ,do.SOFAR
      ,do.EST_RATE
      ,do.EST_MINUTES EST_MIN
from v$asm_operation do
join v$asm_diskgroup dg on dg.GROUP_NUMBER = do.GROUP_NUMBER
order by 2,1
;

