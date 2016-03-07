--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- detail information for a given session over all instances
--
-- Date: 03.03.2016
-- Version: 1
--
-- Parameter 1: SessionID
--

set lines 140
set verify off

column sid format 99999
column serial# format 99999
column username format a20
column status format a8
column ii format 99
column server format a9
column osuser format a10
column PROCESS format 999999
column program format a20
column client_info format a20

select inst_id ii
      ,sid, serial#, username, status, server, osuser, process
      ,to_char(logon_time, 'dd.mm.yy hh24:mi:ss') logon
      ,program
      ,client_info
      ,sql_id
      ,prev_sql_id
      ,ROW_WAIT_FILE#
      ,ROW_WAIT_BLOCK#
      ,ROW_WAIT_ROW#
      ,ROW_WAIT_OBJ#
      ,LAST_CALL_ET
      ,BLOCKING_SESSION_STATUS
      ,BLOCKING_INSTANCE
      ,BLOCKING_SESSION
  from gv$session
 where sid=&1
 order by inst_id
;

