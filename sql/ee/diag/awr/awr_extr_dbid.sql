-- Parameter 1: DB-ID
-- Parameter 2: Begin-Snapid
-- Parameter 3: End-Snapid
-- Parameter 4: DBA_DIRECTORY
--
-- This script exports given Snapshots from AWR to DataPump
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: awr_extr_dbid.sql 99 2010-04-01 05:47:37Z tbr $
--

set echo off heading on underline on;
set verify off

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt AWR-Export for following Instance(s):
select distinct dbid
      ,instance_number inst_num
      ,instance_name inst_name
      ,db_name db_name
from dba_hist_database_instance
where dbid=&1
;

set heading off
set feedback off
set verify off
column spoolfile new_value spoolfile noprint
select 'awrextr_'||'&1'||'_'||'&db_name'||'_'|| '&2'||'_'||'&3' spoolfile from dual;

column directory_name format a30
column directory_path format a80
set lines 120 trimspool on

select directory_name
      ,directory_path
from dba_directories
where directory_name = '&4'
;

prompt &spoolfile
begin
  /* call PL/SQL routine to extract the data */
  dbms_swrf_internal.awr_extract(dmpfile  => '&spoolfile',
                                 dmpdir   => '&4',
                                 bid      => &2,
                                 eid      => &3,
                                 dbid     => &1);
  dbms_swrf_internal.clear_awr_dbid;
end;
/

