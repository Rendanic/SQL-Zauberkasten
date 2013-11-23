 -- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: logstdb_log.sql 102 2010-04-01 13:11:55Z tbr $
-- Displays information from DBA_LOGSTDBY_LOG


set lines 120 pages 100 

column file_name format a65
column SEQUENCE# format 999999
column FIRST_CHANGE# format 999999999
column FIRST_TIME format a14
column APPLIED  format a7
COLUMN DICT_BEGIN FORMAT A10

SELECT FILE_NAME
     , SEQUENCE#
     , APPLIED 
     , FIRST_CHANGE# 
     , to_char(FIRST_TIME,'dd.mm hh24:mi:ss') FIRST_TIME
FROM DBA_LOGSTDBY_LOG
ORDER BY SEQUENCE#;
 
 
