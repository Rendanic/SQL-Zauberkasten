--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: alert_history.sql 232 2010-11-13 18:09:48Z tbr $
--
-- Displays Server Generated Alert History
--
set lines 120
set pages 100

column reason format a90
column rid format 999
column zeit format a18

select reason_id rid
     , to_char(TIME_SUGGESTED, 'dd.mm.yy hh24:mi:ss') zeit
     , reason 
  from (select *
          from DBA_ALERT_HISTORY
         order by sequence_id desc
        )
where rownum < 60
order by TIME_SUGGESTED
;


