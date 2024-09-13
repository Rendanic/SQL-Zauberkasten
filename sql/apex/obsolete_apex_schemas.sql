--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.com)
--
-- Display obsolete APEX_-Schemas in Database
--
-- Date: 13.09.2024
-- Version 1

set lines 80
set pages 10
column username format a20 wrap

SELECT username
  FROM dba_users 
 WHERE (
        username LIKE 'FLOWS\___0_00' ESCAPE '\'
        OR username LIKE 'APEX\___0_00' ESCAPE '\'
       )
   AND username NOT IN (SELECT schema
                          FROM dba_registry
                         WHERE comp_id = 'APEX')
;
