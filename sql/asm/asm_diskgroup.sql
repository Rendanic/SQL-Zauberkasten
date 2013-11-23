--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: asm_diskgroup.sql 145 2010-07-20 20:04:56Z tbr $
--
-- list v$asm_diskgroup with some details
--

set lines 120 pages 100 
column NAME format a30
column STATE format a12
column TOTAL_MB format 9.999.999
column FREE_MB format 9.999.999
column COMPATIBLE format a10
column DB_COMPAT format a10

select NAME
      ,STATE
      ,TOTAL_MB
      ,FREE_MB
      ,COMPATIBILITY COMPATIBLE
      ,DATABASE_COMPATIBILITY DB_COMPAT
from v$asm_diskgroup
;

