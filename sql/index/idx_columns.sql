prompt -- 1. Parameter OWNER
prompt -- 2. Parameter Indexname
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_columns.sql 83 2010-03-23 20:03:59Z tbr $
--
-- List columns of given Index
--
 
set lines 120
set pages 1000
set trimspool on
set verify off

column index_owner format a30
column index_name format a30
column column_name format a30
column column_position format a2
column column_name format a30

select 
      index_owner
     ,index_name
     ,column_name
     ,column_position
  from dba_ind_columns
 where index_owner like '&1'
   and index_name  like '&2'
order by 1,2,4
;

