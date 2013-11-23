--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: set_threshold_example.sql 232 2010-11-13 18:09:48Z tbr $
--
-- examples for setting an alert
--
-- Note:266970.1 Oracle 10G - Server Generated Alerts
--
begin

   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => dbms_server_alert.DB_TIME_WAITING
    ,warning_operator            => dbms_server_alert.operator_ge
    ,warning_value               => '1'
    ,critical_operator           => dbms_server_alert.operator_ge
    ,critical_value              => '90'
    ,observation_period          => 1  -- minutes
    ,consecutive_occurrences     => 1
    ,instance_name               => null
    ,object_type                 => dbms_server_alert.OBJECT_TYPE_session
    ,object_name                 => null

    );
end;
/

begin

   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => dbms_server_alert.USER_TRANSACTIONS_SEC
    ,warning_operator            => dbms_server_alert.operator_ge
    ,warning_value               => '1'
    ,critical_operator           => dbms_server_alert.operator_ge
    ,critical_value              => '90'
    ,observation_period          => 1  -- minutes
    ,consecutive_occurrences     => 1
    ,instance_name               => null
    ,object_type                 => dbms_server_alert.OBJECT_TYPE_system
    ,object_name                 => null

    );
end;
/

begin
   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => dbms_server_alert.PHYSICAL_READS_SEC
    ,warning_operator            => dbms_server_alert.operator_ge
    ,warning_value               => '10'
    ,critical_operator           => dbms_server_alert.operator_ge
    ,critical_value              => '60'
    ,observation_period          => 1  -- minutes
    ,consecutive_occurrences     => 1
    ,instance_name               => null
    ,object_type                 => dbms_server_alert.OBJECT_TYPE_system
    ,object_name                 => null

    );
end;
/

begin
   DBMS_SERVER_ALERT.SET_THRESHOLD
    (metrics_id                  => 2092
    ,warning_operator            => dbms_server_alert.operator_ge
    ,warning_value               => '10'
    ,critical_operator           => dbms_server_alert.operator_ge
    ,critical_value              => '60'
    ,observation_period          => 1  -- minutes
    ,consecutive_occurrences     => 1
    ,instance_name               => null
    ,object_type                 => dbms_server_alert.OBJECT_TYPE_system
    ,object_name                 => null

    );
end;
/
@@alert_thresholds.sql
