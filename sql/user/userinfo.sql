--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: userinfo.sql 30 2010-01-12 20:58:11Z oracle $
--
-- userinfo from dba_users
--
set pages 200
set lines 140

column default_tablespace format a20
column temporary_tablespace format a10
column profile format a20
column account_status format a18
column created format a14
column username format a30

select username
      ,account_status
      ,profile
      ,default_tablespace
      ,temporary_tablespace
      ,to_char(created, 'dd.mm.yy HH24:mi') created
  from dba_users 
 order by username;

