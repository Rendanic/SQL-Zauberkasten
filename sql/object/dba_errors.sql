--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dba_errors.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Display information from dba_errors
--
prompt Parameter 1: Owner
prompt Parameter 2: Object-Name

set lines 140
set pages 100
set verify off


column owner format a20 wrap
column name format a30
column type format a12
column sequence format 9999
column LINE format 999999
column POSITION format 999
column text format a40 wrap

select owner
      ,name
      ,type
      ,sequence
      ,LINE
      ,POSITION
      ,text
from dba_errors
where owner like '&1'
and name like '&2'
order by 1,2,3,4 desc,5;

