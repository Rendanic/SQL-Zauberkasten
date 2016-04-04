--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
--
-- Version: 1
-- Date: 18.03.2016
--
-- Display last 250 entries from DBA_COMMON_AUDIT_TRAILDBA_COMMON_AUDIT_TRAIL
--

set lines 120 pages 200

column OS_USERNAME format a30
column DB_USER format a10
column USERHOST format a10
column OBJECT_NAME format a20
column RETCD format 99999
column NAME format a10
column ATYPE format a10
column OSP format a6
column PRIV_USED format a10

select USERHOST
      ,DB_USER
      ,to_char(EXTENDED_TIMESTAMP, 'dd.mm hh24:mi:ss') TIMESTAMP
      ,RETURNCODE RETCD
      ,b.NAME
      ,decode(audit_type, 'Standard XML Audit', 'XML'
                        , 'SYS XML Audit', 'XML SYS'
                        , 'Mandatory XML Audit', 'XML Mand'
                        , audit_type) atype
      ,OS_PRIVILEGE OSP
      ,PRIV_USED
      ,OBJ_PRIVILEGE
--      ,SYS_PRIVILEGE
--      ,ADMIN_OPTION
--      ,GRANTEE
from (select *
      from DBA_COMMON_AUDIT_TRAIL
      where EXTENDED_TIMESTAMP > sysdate -30
      order by EXTENDED_TIMESTAMP desc
     ) a
join AUDIT_ACTIONS b on  a.ACTION = b.action
where rownum < 250
order by EXTENDED_TIMESTAMP
;
