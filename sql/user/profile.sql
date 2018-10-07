--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 07.10.2018
--
-- Info from dba_profiles

set lines 200 pages 20

column PROFILE format a30
column resource_type format a13
column resource_name format a30
column limit format a20

select profile
     , resource_type
     , resource_name
     , limit
from  dba_profiles
order by 1,3,2;
