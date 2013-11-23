-- Parameter 1: DB-ID
-- Parameter 2: Begin-Snapid
-- Parameter 3: End-Snapid
-- Parameter 4: Instance-Id
-- Parameter 5: Spooldirectory (requires a '/' at the end!)
--
-- This script generates a customized StatspackReport
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spreport_dbid.sql 57 2010-03-13 10:00:31Z tbr $
--

set echo off heading on underline on;
set verify off
set feedback off

define dbid=&1
define begin_snap=&2
define end_snap=&3
define inst_num=&4

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

whenever sqlerror exit rollback

prompt Statspack-Report for following Instance:
select distinct dbid
      ,instance_number inst_num
      ,instance_name inst_name
      ,db_name db_name
from stats$database_instance
where dbid=&dbid
  and instance_number=&inst_num;


set heading off
column spoolfile new_value spoolfile noprint
set echo off
select '&5'||'sp_'||'&db_name'||'_'||'&inst_name'||'_'||ltrim('&inst_num')||'_'||'&dbid'||'_'||'&begin_snap'||'_'||'&end_snap'||'.txt' spoolfile from dual;

define report_name=&spoolfile
prompt &spoolfile

@?/rdbms/admin/sprepins

set feedback on
set heading on
