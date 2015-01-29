REM --------------------------------------
REM Auditing Overview
REM --------------------------------------
REM Uwe Küchler (uwe.kuechler@opitz-consulting.de)
REM

set wrap off
set lines 155 pages 9999
set feedback off

prompt
prompt
prompt ================
prompt Audit Parameters
prompt ================

col NAME        for a20
col VALUE       for a50
col DESCRIPTION for a50
select NAME, VALUE, DESCRIPTION
  from V$PARAMETER
 where NAME like '%audit%'
 order by NAME;

prompt
prompt
prompt ============
prompt Audit Tables
prompt ============

SELECT t.table_name, t.tablespace_name, ROUND( t.blocks * s.block_size / 1024 / 1024, 2 ) MB
  FROM dba_tables t, dba_tablespaces s
 WHERE t.table_name IN ('AUD$', 'FGA_LOG$')
   AND t.tablespace_name = s.tablespace_name
 ORDER BY table_name;


prompt
prompt
prompt =======================
prompt Statement Audit Options
prompt =======================

col USER_NAME        for a15
col PROXY_NAME       for a15

select *
  from DBA_STMT_AUDIT_OPTS
 order by USER_NAME nulls first, PROXY_NAME nulls first, AUDIT_OPTION;


prompt
prompt
prompt =======================
prompt Privilege Audit Options
prompt =======================

col USER_NAME        for a15
col PROXY_NAME       for a15

select *
  from DBA_PRIV_AUDIT_OPTS
 order by USER_NAME nulls first, PROXY_NAME nulls first, PRIVILEGE;


prompt
prompt
prompt ========================
prompt Audit Management Options
prompt ========================

col PARAMETER_NAME    for a30
col PARAMETER_VALUE   for a20
col AUDIT_TRAIL       for a20

select *
  from DBA_AUDIT_MGMT_CONFIG_PARAMS
 order by AUDIT_TRAIL, PARAMETER_NAME;


prompt
prompt
prompt =======================
prompt Last Archival Timestamp
prompt =======================

SELECT * FROM dba_audit_mgmt_last_arch_ts;

prompt
