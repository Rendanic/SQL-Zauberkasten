--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: db_links.sql 88 2010-03-23 20:50:17Z tbr $
--
-- Display all db-links from dba_db_links
--

column owner format a25
column db_link format a30
column username format a20
column host format a25
set pages 100
set lines 120
set verify off

select owner
      ,db_link
      ,username
      ,host
from dba_db_links
order by 1,2
;

