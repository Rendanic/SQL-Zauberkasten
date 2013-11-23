--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplansqlidbind.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for SQL_ID from shared_pool with bind values
--
-- Parameter 1: sql_id
--
set echo off
set verify off
set feedback off

set feedback on

set pages 2000
set lines 200
set trimspool on

column PLAN_TABLE_OUTPUT format a200

--select * from table(dbms_xplan.DISPLAY_CURSOR('&1', 0, 'ALL'));
select t.* 
from v$sql s
join table(dbms_xplan.DISPLAY_CURSOR(s.sql_id,null,'+peeked_binds')) t on 1=1
where s.sql_id='&1';

