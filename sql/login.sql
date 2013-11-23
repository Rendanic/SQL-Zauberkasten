--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: login.sql 54 2010-03-13 08:39:25Z tbr $
--
-- login-Script for SQLPlus
--

set serveroutput on size 1000000
set trimspool on

set lines 120
set pages 1000

set termout off

@session/nlsf

define gname=idle
column global_name new_value gname
select lower(user) || '@' || substr( global_name, 1, decode( dot, 0,
length(global_name), dot-1) ) global_name
  from (select global_name, instr(global_name,'.') dot from global_name );
set sqlprompt '&gname> '
set termout on
set feedback on
