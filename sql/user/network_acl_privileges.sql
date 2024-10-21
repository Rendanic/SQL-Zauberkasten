--
-- Thorsten Bruhns (Thorsten.Bruhns@googlemail.com)
-- Version: 0.1
-- Date: 21.10.2024
--
-- Info from DBA_NETWORK_ACL_PRIVILEGES
set lines 120 pages 200

column PRINCIPAL format a30
column PRIVILEGE format a10
column IS_GRANT format a8
column START_DATE format a10
column END_DATE format a8

select PRINCIPAL
      ,PRIVILEGE
      ,IS_GRANT
      ,to_char(START_DATE, 'dd.mm.yy') start_date
      ,to_char(END_DATE, 'dd.mm.yy') end_date
  from DBA_NETWORK_ACL_PRIVILEGES
 where PRINCIPAL like '&1'
 ORDER BY PRINCIPAL, PRIVILEGE, START_DATE;
