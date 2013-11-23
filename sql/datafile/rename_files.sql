-- Parameter 1: replace 1. Parameter
-- Parameter 2: replace 2. Parameter
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: rename_files.sql 66 2010-03-15 05:20:34Z tbr $
--
-- generates SQL for renaming data-, temp- and redologfiles
--
set lines 2000
set pages 0
set heading off
set verify off

select 'alter database rename file '''||member||''' to '''||replace(member,'&1','&2')||''';' from v$logfile;
 
select 'alter database rename file '''||name||''' to '''||replace(name,'&1','&2')||''';' from v$datafile;
 
select 'alter database rename file '''||name||''' to '''||replace(name,'&1','&2')||''';' from v$tempfile;
 

