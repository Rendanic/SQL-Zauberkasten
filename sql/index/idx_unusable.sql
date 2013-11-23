--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: idx_unusable.sql 83 2010-03-23 20:03:59Z tbr $
--
-- List of all unusable indexes in the database
--
set lines 120
set pages 200

select owner, index_name, status
  from dba_indexes
 where status not in ('VALID', 'N/A')
;

