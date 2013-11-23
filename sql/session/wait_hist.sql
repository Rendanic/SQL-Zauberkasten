--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: wait_hist.sql 233 2010-11-13 20:42:23Z tbr $
--
-- information from v$session_wait_history for SID
--
-- Parameter 1: Oracle SID
--
-- Zitat aus Note Database Performance - FAQ [ID 402983.1]
-- ** Important ** - v$session_wait is often misinterpreted. Often people will assume we are waiting because 
-- see an event and seconds_in_wait is rising. It should be remembered that seconds_in_wait only applies to a
-- current wait if wait_time =0 , otherwise it is actually "seconds since the last wait completed". The other column 
-- of use to clear up the misinterpretation is state which will be WAITING if we are waiting and WAITED% if we are 
-- no longer waiting 

set linesize 140
set heading on
set pagesize 1000

column p1text format a10
column p2text format a10
column p3text format a10
column event format a45
column wt format 99999
column wc format 9999

select vs.sid
      ,vs.wait_time wt
      ,vs.wait_count wc
      ,vs.event
      ,vs.p1text
      ,vs.p1
      ,vs.p2text
      ,vs.p2
      ,vs.p3text
      ,vs.p3
  from V$SESSION_WAIT_HISTORY vs
where vs.sid=&1
order by seq# desc
;
