--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: spparameter.sql 121 2010-06-21 14:17:48Z tbr $
--
-- Displays all Parameters from SPFILE
--

prompt ID = Instance-ID

set pages 1000
set lines 120
set trimspool on
set verify off

column id format 99
column name format a30
column value format a70

select inst_id id
      ,name
      ,value
  from  gv$spparameter
 where ISSPECIFIED='TRUE'
order by name,inst_id;
