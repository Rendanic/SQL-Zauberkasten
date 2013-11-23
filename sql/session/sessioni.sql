--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sessioni.sql 233 2010-11-13 20:42:23Z tbr $
--
-- some other Session Information for given SID
--
-- Parameter 1: SessionID
--

set lines 140
set verify off

column sid format 99999
column serial# format 99999
column username format a20
column status format a8
column server format a9
column osuser format a10
column PROCESS format 999999
column program format a20
column client_info format a20

select sid, serial#, username, status, server, osuser, process
      ,to_char(logon_time, 'dd.mm.yy hh24:mi:ss') logon
      ,program
      ,client_info
  from v$session
 where sid=&1
;


