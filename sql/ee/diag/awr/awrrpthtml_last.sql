-- @param 1: Output Directory (requires a '/' at the end!)
--
-- This script generates the latest HTML-AWR-Report
--
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.de)
-- 2014-04-03

set echo off heading on underline on;
set verify off

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;
column sn_start  heading "Start Sn"  new_value sn_start  format 99999;
column sn_end    heading "End Sn"    new_value sn_end    format 99999;

prompt AWR-Report for following Instance:
select distinct dbid
      ,instance_number inst_num
      ,instance_name inst_name
      ,db_name db_name
from dba_hist_database_instance
where dbid=( select DBID from gv$database )
  and instance_number=( select instance_number from v$instance );

select max(snap_id)-1 SN_START, max(snap_id) SN_END from dba_hist_snapshot;

set heading off
set feedback off
set verify off
column spoolfile new_value spoolfile noprint
select '&1'||&dbid||'_awrrpt_'||&sn_start||'_'||&sn_end||'.html' spoolfile from dual;

prompt &spoolfile
set feedback off termout off lines 8000 pages 0 trimspool on

spool &spoolfile
select output
from table(dbms_workload_repository.awr_report_html(&dbid
                                                   ,&inst_num
                                                   ,&sn_start
                                                   ,&sn_end
                                                  )
          )
;
spool off

set feedback on termout on heading on pages 9999 lines 120
prompt Done.
exit
