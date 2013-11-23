--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: network_acls.sql 242 2010-11-14 13:47:23Z tbr $
--
-- dba_network_acls
--
set lines 120 pages 200

column HOST format a20
column LOWER_PORT format 99999
column UPPER_PORT format 99999
column ACL format a50

select HOST
      ,ACL
	  ,LOWER_PORT
	  ,UPPER_PORT
  from dba_network_acls;




