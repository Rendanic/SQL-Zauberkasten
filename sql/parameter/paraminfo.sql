--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: paraminfo.sql 121 2010-06-21 14:17:48Z tbr $
--
-- Detailinfo for a parameter
--
--
prompt Parameter 1: init.ora Parametername
prompt ID = Instance-ID

set lines 120
set pagesize 100
set trimspool on
set verify off

column id format 99
column name format a30
column value format a45
column DEFAUL format a5
column MODIFI format a5
column DESCRIPTION format a25

select inst_id id
      ,name
      ,value
      ,ISDEFAULT DEFAUL
      ,ISMODIFIED MODIFI
      ,DESCRIPTION
from gv$parameter
where name like ('&1')
order by inst_id,name
;

