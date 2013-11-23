--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: gather_schema_stale9i.sql 10 2008-11-11 10:25:06Z oracle $
--
-- gather stale statistics with 10% and xolumns size 1, degree 4
--
-- Note:237901.1 Subject: 	Gathering Schema or Database Statistics Automatically - Examples
--
-- 9i:
-- SQL> exec dbms_stats.ALTER_SCHEMA_TAB_MONITORING('<owner>',TRUE);
-- SQL> exec dbms_stats.ALTER_DATABASE_TAB_MONITORING(TRUE);

set timing on
set echo on
set serverout on

declare
  tObjectTab        dbms_stats.ObjectTab;
begin
   DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
   dbms_stats.gather_schema_stats(ownname          => '&1'
                                ,estimate_percent => 10
                                ,method_opt       => 'FOR ALL COLUMNS SIZE 1'
                                ,degree           => 4
                                ,granularity      => 'ALL'
                                ,options          => 'GATHER STALE'
                                ,objlist          => tObjectTab
                                ,cascade          => true
                                ,no_invalidate    => false
                                );
   if tObjectTab.count > 0
   then
      for i in tObjectTab.first .. tObjectTab.last
      loop
         dbms_output.put_line(lpad(tObjectTab(i).ownname,30)||'.'||lpad(tObjectTab(i).objname,30)||' '|| lpad(tObjectTab(i).partname,30));
      end loop;
   end if;
end;
/

