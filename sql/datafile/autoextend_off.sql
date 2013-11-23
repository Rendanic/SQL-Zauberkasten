--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: autoextend_off.sql 66 2010-03-15 05:20:34Z tbr $
--
-- Generats SQLl for disabling autoextend on all data- and tempfiles
--
set trimspool on
set lines 2000
set pages 0
select 'alter database '||decode(typ,1,'datafile',2,'tempfile')||' '''|| file_name|| ''' autoextend on maxsize unlimited;'
from (select file_name, autoextensible, 1 typ
        from dba_data_files
       union all
      select file_name, autoextensible, 2 typ
        from dba_temp_files
     )
where autoextensible = 'YES'
;

select 'alter database '||decode(typ,1,'datafile',2,'tempfile')||' '''|| file_name|| ''' autoextend off;'
from (select file_name, autoextensible, 1 typ
        from dba_data_files
       union all
      select file_name, autoextensible, 2 typ
        from dba_temp_files
     )
where autoextensible = 'YES'
;
 

