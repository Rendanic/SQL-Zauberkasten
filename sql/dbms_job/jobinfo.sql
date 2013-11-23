--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: jobinfo.sql 69 2010-03-15 20:20:53Z tbr $
--
-- list existing jobs from dba_jobs
--
set pages 100
set lines 140
set trimspool on


column what format a40
column interval format a20
column job format 99999
column schema_user format a20
column f format 99
column b format a3
select job
      ,failures f
      ,broken b
      ,schema_user
      ,what
      ,interval
      ,to_char(next_date, 'dd.mm.yy HH24:MI:SS') next_date
  from dba_jobs
order by job
;
