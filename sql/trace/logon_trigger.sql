  --
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: stopall_sqltrace.sql 253 2010-11-23 21:34:55Z tbr $
--
-- example for a logon trigger for event 10046
--
--
-- Recommended Method for Obtaining 10046 trace for Tuning [ID 376442.1]
CREATE OR REPLACE TRIGGER set_trace
AFTER LOGON ON DATABASE
DECLARE
--      lcommand varchar(200);
   l_vergeich varchar2(2000);
BEGIN
  SELECT SYS_CONTEXT('USERENV','CLIENT_INFO')   
  into l_vergeich
  from dual;

  if l_vergeich = ''
  then
    EXECUTE IMMEDIATE 'alter session set tracefile_identifier='''|| l_vergeich ||''''; 
    EXECUTE IMMEDIATE 'alter session set statistics_level=ALL'; 
    EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
    EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
  end if;
END set_trace;
/

