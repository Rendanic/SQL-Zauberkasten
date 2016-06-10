-- Parameter 1: DB-ID
-- Parameter 2: Begin (yymmddhh24mi)
-- Parameter 3: End (yymmddhh24mi)
-- Parameter 4: Instance-Id
-- Parameter 5: Spooldirectory (requires a '/' at the end!)
--
-- Generate an ASH-Report for all Sessions on Instance
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--

set echo off heading on underline on;
set verify off

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt ASH-Report for following Instance:
select distinct dbid
      ,instance_number inst_num
      ,instance_name inst_name
      ,db_name db_name
from dba_hist_database_instance
where dbid=&1
  and instance_number=&4;

set heading off
set feedback off
set verify off
column spoolfile new_value spoolfile noprint
select '&5.&1._ashrpt_&2._&3._&4..txt' spoolfile from dual;

prompt &spoolfile

set feedback off
spool &spoolfile
select output
from table(dbms_workload_repository.ASH_GLOBAL_REPORT_TEXT(&1
                                                   ,&4
                                                   ,to_date('&2', 'yymmddhh24mi')
                                                   ,to_date('&3', 'yymmddhh24mi')
                                                  )
          )
;
spool off

set feedback on
set heading on
