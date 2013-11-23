--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: ospid.sql 233 2010-11-13 20:42:23Z tbr $
--
-- Display Information for a given SID from v$session
--
-- Parameter 1: SID 
--

set lines 120
set pages 100

column pid format 99999
column spid format 999999
column username format a30
column machine format a30
column osuser format a20

select vp.pid
      ,vp.spid
	  ,vp.username osuser
      ,vs.machine
      ,vs.username
  from v$process vp
join v$session vs on vs.PADDR = vp.addr
where vs.sid= &1
;

