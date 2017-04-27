

--set arrays 72
set arrays 100
--set lines 110
set lines 140
set head off
set tab off
set pages 0
set echo on
set serveroutput on format wrapped
    SELECT *   FROM   TABLE(&1..moats.top(&2));

