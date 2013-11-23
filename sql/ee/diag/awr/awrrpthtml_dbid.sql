-- Parameter 1: DB-ID
-- Parameter 2: Begin-Snapid
-- Parameter 3: End-Snapid
-- Parameter 4: Instance-Id
-- Parameter 5: Spooldirectory (requires a '/' at the end!)
--
-- This script generates a customized HTML-AWR-Report
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awrrpthtml_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--

set echo off heading on underline on;
set verify off

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt AWR-Report for following Instance:
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
select '&5'||'&1'||'_awrrpt_'||'&2'||'_'||'&3'||'.txt' spoolfile from dual;

prompt &spoolfile
feedback off

spool &spoolfile
select output
from table(dbms_workload_repository.awr_report_text(&1
                                                   ,&4
                                                   ,&2
                                                   ,&3
                                                  )
          )
;
spool off

set feedback on
set heading on

select distinct dbid
      ,instance_number inst_num
      ,instance_name inst_name
      ,db_name db_name
from dba_hist_database_instance
where dbid=&1
  and instance_number=&4;
