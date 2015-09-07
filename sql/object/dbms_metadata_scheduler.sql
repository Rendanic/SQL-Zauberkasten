--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- prints DDL from dbms_metadata for PROC
--
-- Scheduler Jobs must be exported with TYPE=PROCOBJ
-- There is no special parameter for the different object types for scheduler
-- jobs.
-- Export of scheduler Objects from SYS-Schema is not possible at the
-- moment. (Tested until 12.1.0.2)

--

prompt 1. Parameter : OWNER
prompt 2. Parameter : OBJECT_NAME

set long 10000000
set longchunksize 10000000
set lines 2000
set pages 0
set trimspool on
set heading off

begin
   DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
   DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
end;
/

select dbms_metadata.get_ddl('PROCOBJ', '&2', '&1')
  from dual;

set heading on
