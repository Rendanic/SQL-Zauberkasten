--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: network_acl.sql 380 2012-01-23 12:18:12Z tbr $
--
-- Displays NETWORK_ACLS from Data-Dictionary
--
column PRINCIPAL format a30
column PRIVILEGE format a10
column IS_GRANT format a6
column START_DATE format a10
column END_DATE format a10
column host format a20
column lport format 99999
column uport format 99999
set lines 140 

select a.PRINCIPAL
      ,a.PRIVILEGE
      ,a.IS_GRANT
      ,to_char(a.START_DATE,'dd.mm.yy') START_DATE
      ,to_char(a.END_DATE,'dd.mm.yy') END_DATE
      ,INVERT
      ,b.host
      ,LOWER_PORT lport
      ,UPPER_PORT uport
from dba_network_acl_privileges a
join dba_network_acls b on a.ACLID = b.ACLID
order by 1,2;
