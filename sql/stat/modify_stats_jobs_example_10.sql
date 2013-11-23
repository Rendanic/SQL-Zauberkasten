--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: modify_gather_stats_jobs.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Examle for modifying the default statistic job
-- 10g related!
--
BEGIN
DBMS_SCHEDULER.DISABLE(
Name=>'"SYS"."WEEKNIGHT_WINDOW"',
force=>TRUE);
END;
/

BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE(
name=>'"SYS"."WEEKNIGHT_WINDOW"',
attribute=>'REPEAT_INTERVAL',
value=>'freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=&startstunde;byminute=&startminute; bysecond=0'
);
END;
/

BEGIN
DBMS_SCHEDULER.ENABLE(
name=>'"SYS"."WEEKNIGHT_WINDOW"');
END; 
/
