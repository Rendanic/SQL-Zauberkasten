--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: nondefaultparam.sql 121 2010-06-21 14:17:48Z tbr $
--
-- Displays all non default init.ora-Parameter 
--

prompt ID = Instance-ID

set pages 1000
set lines 120
set trimspool on

column id format 99
column name format a30
column value format a80

select inst_id id
      ,name
      ,value
  from gv$parameter
 where isdefault != 'TRUE'
order by name,inst_id;
