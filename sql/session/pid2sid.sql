--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pid2sid.sql 233 2010-11-13 20:42:23Z tbr $
--
-- get session information for process id
--
-- Parameter 1: Oracle SessionID
--
set lines 120
set pages 100

column sid format 9999
column serial# format 99999
column pid format 99999
column spid format 99999
column osuser format a20
column machine format a30
column username format a30

select vs.sid
      ,vs.serial#
      ,vp.pid
	  ,vp.spid
      ,vp.username osuser
      ,vs.machine
      ,vs.username
  from v$process vp
join v$session vs on vs.PADDR = vp.addr
where vp.spid= &1
;

