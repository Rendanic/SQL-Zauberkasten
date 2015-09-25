--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Version: 1
-- Date   : 25.11.2013
--
-- Display information from v$pdbs
--

set lines 120
set pages 100
set verify off


column NAME format a40
column DBID format 999999999999
column status format a13

select NAME
      ,DBID
      ,OPEN_MODE
      ,restricted
      ,RECOVERY_STATUS RECOVERY
      ,sum(total_size)/1024/1024 ts_MB
  from v$pdbs
  group by grouping sets((name, dbid, open_mode, restricted, RECOVERY_STATUS)
                        ,()
                        )
order by 1;
