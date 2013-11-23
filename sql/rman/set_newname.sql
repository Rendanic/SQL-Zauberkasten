--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: set_newname.sql 221 2010-11-01 21:33:50Z tbr $
--
-- spool set newname for all files
--
set lines 2000
set pages 0
set trimspool on
set feedback off


select 'set newname for '|| decode(typ, '1', 'datafile','2','tempfile')||' '|| file_id || ' to '
     ||''''|| file_name||''';'
from (select file# file_id, name file_name, '1' typ
        from v$datafile
      union all
     select file# file_id, name file_name, '2' typ 
       from v$tempfile
    )
order by file_id;


set feedback on


