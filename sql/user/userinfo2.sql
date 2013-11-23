--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: userinfo2.sql 10 2008-11-11 10:25:06Z oracle $
--
-- userinfo from dba_users with lock and expire-date
--
set pages 200
set lines 140

column profile format a20
column account_status format a18
column lchange format a14
column lock_date format a14
column expiry_date format a14
column username format a30

select du.username
      ,du.account_status
      ,du.profile
      ,to_char(u.ptime, 'dd.mm.yy HH24:mi') lchange
      ,to_char(du.lock_date, 'dd.mm.yy HH24:mi') lock_date
      ,to_char(du.expiry_date, 'dd.mm.yy HH24:mi') expiry_date
  from dba_users du,sys.user$ u
 where du.username = u.name
 order by username;

