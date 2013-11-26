--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: connect_info.sql 832 2013-08-12 04:06:01Z tbr $
--
-- v$session_connect_info for all sessions
--
set linesize 200
set heading on
set pagesize 1000
column sid format 99999
column osuser format a15
column NETWORK_SERVICE_BANNER format a95

SELECT SID, OSUSER,NETWORK_SERVICE_BANNER 
  FROM V$SESSION_CONNECT_INFO
  WHERE (LOWER(NETWORK_SERVICE_BANNER) LIKE '%authentication service%'
     OR LOWER(NETWORK_SERVICE_BANNER) LIKE '%encryption service%'
     OR LOWER(NETWORK_SERVICE_BANNER) LIKE '%crypto_checksumming%')
  ORDER by 1;
