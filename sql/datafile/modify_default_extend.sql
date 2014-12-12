--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Spool alter database datafile for default next extend
--
-- Date: 29.09.2014

set lines 2000 pages 1000 trimspool on


select 'alter database datafile ' || FILE_ID || ' autoextend on next 1m;'
from dba_data_files
where AUTOEXTENSIBLE='YES'
and INCREMENT_BY < 10;

