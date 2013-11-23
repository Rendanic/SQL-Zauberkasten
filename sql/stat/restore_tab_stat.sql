--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: restore_stat.sql 10 2008-11-11 10:25:06Z oracle $
--
-- create list of restore_table_stats for given parameters
--
-- Parameter 1: Owner 
-- Parameter 2: Table-Name
--
set lines 240
set pages 100
set trimspool on
set heading off
set feedback off

select 'exec dbms_stats.restore_table_stats('
        ||''''||OWNER||''''
        ||','''||table_name||''''
        ||',as_of_timestamp=>to_date('''||to_char(STATS_UPDATE_TIME,'dd.mm.yy hh24:mi:ss')||''''
        ||',''dd.mm.yy hh24:mi:ss'')'
        ||',force=>true,no_invalidate=>false);'
  from DBA_TAB_STATS_HISTORY
 where OWNER like ('&1')
   and TABLE_NAME like ('&2')
;

set heading on
set feedback on
