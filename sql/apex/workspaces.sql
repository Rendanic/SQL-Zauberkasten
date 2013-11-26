--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: workspaces.sql 890 2013-09-02 10:12:13Z tbr $
--
-- Display Informations for all APEX-Workspaces

set lines 140
set pages 100
column workspace_id format 9999999999999999999
column workspace format a20 wrap
column users format 999
column devel format 99
column apps format 99
column schem format 99
column files format 99999

select workspace_id
     , workspace 
     , to_char(CREATED_ON, 'dd.mm.yy hh24:mi') created_on
     , to_char(LAST_LOGGED_PAGE_VIEW, 'dd.mm.yy hh24:mi') last_page_view
     , SCHEMAS schem
     , FILES 
     , APPLICATIONS apps
     , APEX_USERS users
     , APEX_DEVELOPERS devel
from apex_workspaces
order by workspace
;


