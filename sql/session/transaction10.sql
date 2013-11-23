--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: transaction10.sql 233 2010-11-13 20:42:23Z tbr $
--
-- active transactions with running sqlstatement
-- usable from Oracle 10g onwards
--
set lines 120

column username format a20
column sid format 9999
column sql_text format a50
column status format a8
column log_mb format 999999
column start_time format a9

SELECT distinct --t.ADDR,
t.status,
s.sid,
t.start_time,
t.used_ublk,
t.used_urec,
trunc(t.log_io / 1024 / 1024) AS log_mb,
t.phy_io,
q.sql_text
FROM v$transaction t,
v$session s,
v$sql q
WHERE s.taddr(+) = t.addr
AND s.sql_id = q.sql_id(+)

/

