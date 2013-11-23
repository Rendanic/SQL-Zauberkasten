--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pqslave.sql 96 2010-03-24 05:52:08Z tbr $
--
-- Information regarding parallel query slaves
--

set lines 120
set pages 100
set trimspool on

column idlcur format 9999
column buscur format 9999
column cpuc format 9999
column msgsc format 9999999
column msgrc format 9999999
column idltot format 9999
column bustot format 9999
column cputot format 9999
select SLAVE_NAME
      ,STATUS
--      ,SESSIONS
      ,IDLE_TIME_CUR idlcur
      ,BUSY_TIME_CUR buscur
      ,CPU_SECS_CUR cpuc
      ,MSGS_SENT_CUR msgsc
      ,MSGS_RCVD_CUR msgrc
      ,IDLE_TIME_TOTAL idltot
      ,BUSY_TIME_TOTAL bustot
      ,CPU_SECS_TOTAL cputot
      ,MSGS_SENT_TOTAL msgst
      ,MSGS_RCVD_TOTAL msgrt
from  V$PQ_SLAVE
order by status,SLAVE_NAME ;

