--
-- Thorsten Bruhns (Thorsten.Bruhns@googlemail.com)
-- Version: 0.2
-- Date: 21.10.2024
--
-- Information about network ACLs for users
set lines 120 pages 200

column HOST format a30
column LOWER_PORT format 99999
column UPPER_PORT format 99999
column PRINCIPAL format a30
column PRIVILEGE format a10
column IS_GRANT format a8
column START_DATE format a10
column END_DATE format a8

select nap.PRINCIPAL
      ,PRIVILEGE
      ,na.HOST
      ,na.LOWER_PORT
      ,na.UPPER_PORT
      ,IS_GRANT
      ,to_char(START_DATE, 'dd.mm.yy') start_date
      ,to_char(END_DATE, 'dd.mm.yy') end_date
  from dba_network_acls na
  join DBA_NETWORK_ACL_PRIVILEGES nap on nap.acl = na.acl
 where PRINCIPAL like '&1'
 ORDER BY nap.PRINCIPAL, na.host, nap.PRIVILEGE, nap.START_DATE;
