--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dbc_license.sql 380 2012-01-23 12:18:12Z tbr $
-- 
-- Displays active licenses in Database Console
-- This script requires an existing SYSMAN-Schema
--
set lines 150 heading on pages 100
column TARGET_NAME format a30
column TARGET_TYPE format a30
column PACK_NAME format a40

select TARGET_NAME
      ,TARGET_TYPE
	  ,PACK_NAME 
from sysman.MGMT_LICENSE_VIEW 
order by 1,2,3;

