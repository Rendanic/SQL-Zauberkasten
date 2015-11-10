--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- enable autoextend on all datafiles with maxsize
--
-- Date: 10.11.2015
--
-- Parameter 1: Size for maxsize. example: 2g
--

declare
  str varchar2(2000);
begin
  for cur1 in (select file#, 'datafile' typ
               from v$tempfile
               union all
               select file#, 'tempfile'
               from v$tempfile)
  loop
    str := 'alter database ' || cur.typ || ' ' || cur1.file# || ' autoextend on next 100m maxsize &1';
    dbms_output.put_line(str);


  end loop;
end;
/

