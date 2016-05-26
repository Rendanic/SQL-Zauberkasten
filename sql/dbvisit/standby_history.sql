--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- History of Archivelogs in DBVisit Standby for last 12 hours
--
-- Date: 26.05.2016
--
-- Parameter 1: DBVisit Schemaowner

COLUMN ORA_SID FORMAT A8
COLUMN date FORMAT a16
COLUMN AL_GAP FORMAT 9999
COLUMN TR_GAP FORMAT 9000
COLUMN PLOGSEQ FORMAT 99999999
COLUMN PARCSEQ FORMAT 99999999
COLUMN DBVLSEQ FORMAT 99999999
COLUMN th format 99

SELECT oracle_sid ORA_SID
      , to_char(datestamp, 'dd.mm hh24:mi:ss') "date"
      , archive_log_gap AL_GAP
      , TRANSFER_LOG_GAP TR_GAP
      , PRIMARY_LOG_SEQUENCE PLOGSEQ
      , PRIMARY_ARCHLOG_SEQUENCE PARCSEQ
      , DBVISIT_LAST_SEQUENCE DBVLSEQ
      , THREAD_NUM th
FROM &1..dbv_sequence_log
where datestamp > sysdate-1/12
ORDER BY datestamp, oracle_sid;


