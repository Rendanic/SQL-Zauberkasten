--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: nondefaultparam.sql 121 2010-06-21 14:17:48Z tbr $
--
-- Displays changed deprecated  parameters
--

prompt ID = Instance-ID

set pages 1000
set lines 120
set trimspool on

column id format 99
column name format a30
column value format a80

select a.inst_id id
      ,a.name
      ,a.value
  from gv$parameter a
 where a.isdefault != 'TRUE'
   and ISDEPRECATED = 'TRUE'
order by a.name,a.inst_id;
