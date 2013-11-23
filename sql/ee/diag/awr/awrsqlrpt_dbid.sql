-- Parameter 1: DBID
-- Parameter 2: Begin-Snapid
-- Parameter 3: End-Snapid
-- Parameter 4: Instance-Num
-- Parameter 5: Spooldirectory
-- Parameter 6: sql_id
--
-- Generates a awrsqlrpt for given parameters
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awrsqlrpt_dbid.sql 111 2010-04-07 07:05:36Z tbr $
--

set echo off heading on underline on;
set verify off

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

set heading off
set feedback off
set verify off
column spoolfile new_value spoolfile noprint
select '&5'||'&1'||'_'||'&6'||'_awrsqlrpt_'||'&2'||'_'||'&3'||'.txt' spoolfile from dual;

prompt &spoolfile

spool &spoolfile
select output
from table(dbms_workload_repository.awr_sql_report_text(&1
                                                   ,&4
                                                   ,&2
                                                   ,&3
                                                   ,'&6'
                                                  )
          )
;


spool off
set feedback on
set heading on
