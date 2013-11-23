 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: change_tables.sql 246 2010-11-23 19:37:50Z tbr $
--
-- Displays information for change-sets
--

set lines 120 pages 100

column publisher format a20
column set_name format a30
column change_source_name format a30
column iddl format a4
column cen format a3
column sod format a3
column cerr format a4

select publisher
     , set_name
     , change_source_name
     , ignore_ddl iddl
     , capture_enabled cen
     , stop_on_ddl sod
     , capture_error cerr
from change_sets
where publisher is not null
;
