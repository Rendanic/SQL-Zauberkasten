--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplansid.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for running sql on session with SID
--
-- Parameter 1: SID


set echo off
set verify off
set feedback off

variable SQL_ID varchar2(20)
variable SQL_CHILD_NUMBER number


begin
   select SQL_ID
         ,SQL_CHILD_NUMBER
     into :SQL_ID
         ,:SQL_CHILD_NUMBER
     from v$session
    where sid = &&1;
end;
/

set feedback on

set pages 2000
set lines 200
set trimspool on

column PLAN_TABLE_OUTPUT format a200

select * from table(dbms_xplan.DISPLAY_CURSOR(:SQL_ID, :SQL_CHILD_NUMBER, 'ALL'));


