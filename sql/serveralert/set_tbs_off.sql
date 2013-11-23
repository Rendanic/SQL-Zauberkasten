--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: set_tbs_off.sql 232 2010-11-13 18:09:48Z tbr $
--
-- Disable an alert for a known Tablespace
--

prompt 1. parameter: tablespace name

-- Note:392268.1 How To Exclude a Tablespace From The Tablespace Used (%) Metric
-- Note:266970.1 Oracle 10G - Server Generated Alerts
-- Note:271585.1 Configuring Server-Generated Alerts for Tablespace Usage using PL/SQL and Advanced Queues


declare
   tbsname      varchar2(30) := '&1';
begin
   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => dbms_server_alert.TABLESPACE_PCT_FULL
    ,warning_operator            => dbms_server_alert.operator_do_not_check
    ,warning_value               => '0'
    ,critical_operator           => dbms_server_alert.operator_do_not_check
    ,critical_value              => '0'
    ,observation_period          => 1  -- minutes
    ,consecutive_occurrences     => 1
    ,instance_name               => null
    ,object_type                 => dbms_server_alert.object_type_tablespace
    ,object_name                 => upper(tbsname)
    );
end;
/


-- dbms_server_alert.TABLESPACE_PCT_FULL
@@alert_thresholds.sql
