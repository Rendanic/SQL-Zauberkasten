--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: imp_stat_table.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Import Tablestattistics
--
rem Note:117203.1 Subject: 	How to Use DBMS_STATS to Move Statistics to a Different Database
prompt 1. Stattabowner
prompt 2. Stattable
prompt 3. Destination owner
prompt 4. destination table
begin
   dbms_stats.import_table_stats(statown       => '&1'
                                ,stattab       => '&2'
                                ,ownname       => '&3'
                                ,tabname       => '&4'
                                ,cascade       => true
                                ,no_invalidate => false
                                ,force         => true
                                );
end;
/

                                  
