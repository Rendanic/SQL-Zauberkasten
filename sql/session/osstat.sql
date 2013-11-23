--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: osstat.sql 233 2010-11-13 20:42:23Z tbr $
--
-- get Information from v$osstat for given seconds
--
-- Parameter 1: time in seconds
--
set verify off
set lines 100
set feedback off
set serverout on
alter session set statistics_level='ALL';
declare
  cursor cur_osstat
  is
  select *
  from v$osstat
  where stat_name not like 'AVG%'
  order by OSSTAT_ID;

  type typ_osstat is table of v$osstat%rowtype index by pls_integer;
  t_osstat_old   typ_osstat;
  t_osstat_new   typ_osstat;
begin
  dbms_output.enable;

  open cur_osstat;

  fetch cur_osstat
  bulk collect 
  into t_osstat_old;

  close cur_osstat;
  
  dbms_lock.sleep(&1);
  
  open cur_osstat;

  fetch cur_osstat
  bulk collect 
  into t_osstat_new;

  close cur_osstat;
 
  dbms_output.put_line('Interval: &1 Sekunden Sysdate: ' 
                       || to_char(sysdate,'dd.mm.yyyy hh24:mi:ss') 
                       || ' numbers in hundredths of a second '); 
  for i in t_osstat_old.first .. t_osstat_old.last
  loop
    declare
      v_value   number;
    begin
    if t_osstat_old(i).osstat_id not in (0,7,8,9,10,11,15,1008)
    then
      v_value := t_osstat_new(i).value - t_osstat_old(i).value;
    else
      v_value := t_osstat_old(i).value;
    end if;
    dbms_output.put_line(rpad(t_osstat_old(i).stat_name,35) || to_char(v_value));
    end;
  end loop;
end;
/

set feedback on
