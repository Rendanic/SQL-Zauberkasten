PROMPT -- Parameter 1: tuning task name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: journal.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Displays a journal for a tuning task
--
set lines 120
set pages 1000
set verify off

column journal_entry format a30

select *
from DBA_ADVISOR_JOURNAL
where task_name like '&1';

