--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: userinfo12.sql 826 2013-08-10 08:35:34Z tbr $
--
-- userinfo from dba_users from RDBMS12c
--
set pages 200
set lines 140

column default_tablespace format a20
column temporary_tablespace format a10
column PWD_VER format a8
column account_status format a18
column last_login format a14
column created format a14
column username format a30

select username
      ,account_status
      ,PASSWORD_VERSIONS PWD_VER
      ,ORACLE_MAINTAINED om
      ,COMMON
      ,to_char(LAST_LOGIN, 'dd.mm.yy HH24:mi') last_login
      ,to_char(created, 'dd.mm.yy HH24:mi') created
  from dba_users 
 order by username;

