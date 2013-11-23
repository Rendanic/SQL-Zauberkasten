--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: progress.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Information for a running Recovery-Operation

set lines 120
set pages 100
set trimspool on

column stime format a8
column type format a20
column item format a25
column units format a20
column sofar format 9999999
column total format 9999999

select to_char(start_time,'HH24:mi:ss') stime
      ,type
      ,item
      ,units
      ,sofar
      ,total 
      ,TIMESTAMP
from V$RECOVERY_PROGRESS;

