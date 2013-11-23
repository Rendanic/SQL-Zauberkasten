--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dplan9i.sql 244 2010-11-14 14:35:23Z tbr $
--
-- display plan for statement_id
--
-- Parameter 1: statement_id
--
set pages 2000
set lines 200
set trimspool on
 
column PLAN_TABLE_OUTPUT format a200
 
delete from plan_table
where statement_id ='&&1'
---@@sql9

insert into plan_table
(STATEMENT_ID,
 TIMESTAMP,
 REMARKS,
 OPERATION,
 OPTIONS,
 OBJECT_NODE,
 OBJECT_OWNER,
 OBJECT_NAME,
 OBJECT_INSTANCE,
 OBJECT_TYPE,
 OPTIMIZER,
 SEARCH_COLUMNS,
 ID,
 PARENT_ID,
 POSITION,
 COST,
 CARDINALITY,
 BYTES,
 OTHER_TAG,
 PARTITION_START,
 PARTITION_STOP,
 PARTITION_ID,
 OTHER,
 DISTRIBUTION,
 CPU_COST,
 IO_COST,
 TEMP_SPACE,
 ACCESS_PREDICATES,
 FILTER_PREDICATES
)
select /*+ rule */
 '&&1',
 sysdate,
 'REMARKS',
 OPERATION,
 OPTIONS,
 OBJECT_NODE,
 OBJECT_OWNER,
 OBJECT_NAME,
 0,
 'OBJECT_TYPE',
 OPTIMIZER,
 SEARCH_COLUMNS,
 ID,
 PARENT_ID,
 POSITION,
 COST,
 CARDINALITY,
 BYTES,
 OTHER_TAG,
 PARTITION_START,
 PARTITION_STOP,
 PARTITION_ID,
 OTHER,
 DISTRIBUTION,
 CPU_COST,
 IO_COST,
 TEMP_SPACE,
 ACCESS_PREDICATES,
 FILTER_PREDICATES
from
 v$sql_plan 
where
  address = (select SQL_ADDRESS from v$session b where sid=&&1);

--@@sql9

SELECT * FROM table(DBMS_XPLAN.DISPLAY('PLAN_TABLE', '&&1'));

