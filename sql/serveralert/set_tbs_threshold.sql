--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: set_tbs_threshold.sql 232 2010-11-13 18:09:48Z tbr $
--
-- set a threshold for a given Tablespace
--
prompt 1. parameter: tablespace (null) for all TBS
prompt 2. warning threshold in %
prompt 3. error   threshold in %

-- Note:392268.1 How To Exclude a Tablespace From The Tablespace Used (%) Metric
-- Note:266970.1 Oracle 10G - Server Generated Alerts
-- Note:271585.1 Configuring Server-Generated Alerts for Tablespace Usage using PL/SQL and Advanced Queues


declare
   tbsname      varchar2(30) := '&1';
begin
   if (nvl(tbsname, 'null') = 'null')
   then
      tbsname := null;
   end if;

   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => dbms_server_alert.TABLESPACE_PCT_FULL
    ,warning_operator            => dbms_server_alert.operator_ge
    ,warning_value               => '&2'
    ,critical_operator           => dbms_server_alert.operator_ge
    ,critical_value              => '&3'
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
