-- Parameter 1: db_name
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: catalog_backuppiece.sql 222 2010-11-01 21:48:49Z tbr $
--
-- create catalog backuppiece from catalog for db_name
--
set lines 400
set pages 10000

set trimspool on

set heading off
set verify off

select 'catalog backuppiece '''|| handle ||''';'
from rman.rc_backup_piece rb
join rman.rc_database rd on rd.db_key = rb.db_key
where rd.name = '&1';


