--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dba_tab_priv.sql 10 2008-11-11 10:25:06Z oracle $
--
-- dba_tab_privs for an object
--
-- Parameter 1: Owner
-- Parameter 2: Object-Name
--

column GRANTEE format a20
column owner format a20
column table_name format a30
column grantor format a20
column privilege format a30

set pages 2000
set lines 140

select GRANTEE
      ,OWNER
      ,TABLE_NAME
      ,GRANTOR
      ,PRIVILEGE
from dba_tab_privs
where owner like '&1'
and table_name like '&2'
order by 2,3,1
;

