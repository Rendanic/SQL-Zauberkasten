prompt -- 1. Parameter OWNER
prompt -- 2. Parameter Indexname
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_info.sql 83 2010-03-23 20:03:59Z tbr $
--
-- Some Information for given Index
--
 
set lines 1000
set pages 1000
set trimspool on

column tablespace_name format a24
column st format a3
column idxt format a10

select owner
      ,table_name
      ,index_name
      ,decode(status,'VALID', 'V'
                    ,'N/A' , 'NA'
                    ,status) st
      ,num_rows
      ,TEMPORARY TMP
      ,TABLESPACE_NAME
      ,index_type idxt
      ,to_char(last_analyzed, 'dd.MM.YY HH24:MI') analyzed
  from dba_indexes
 where owner like '&1'
   and index_name like '&2'
;
