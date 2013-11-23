--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: imp_stat_schema2.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Import schema Statistics from table, ignore non existing partitions
--
-- Parameter 1: Owner of statistic table
-- Parameter 2: Table-Name of statistic table

begin
  for rec in (select * 
              from dba_tables 
              where owner = '&1'
              and PARTITIONED !='YES'
             )
  loop
    begin
    dbms_stats.import_table_stats(statown         => rec.owner
                                 ,stattab         => '&2'
                                 ,ownname         => rec.owner
                                 ,tabname         => rec.table_name
                                 ,cascade       => true
                                 ,no_invalidate => false
                                 ,force         => true
                                 );
    dbms_output.put_line('Statistiken von '||rec.owner||'.'||rec.table_name||' erfolgreich importiert');
    exception
    when others then
      dbms_output.put_line('Fehler bei: '||rec.owner||'.'||rec.table_name||' '||sqlcode||' ' || sqlerrm);
    end;
  end loop;

  for rec in (select * 
              from dba_tab_partitions
              where table_owner = '&1'
             )
  loop
    begin
    dbms_stats.import_table_stats(statown         => rec.table_owner
                                 ,stattab         => '&2'
                                 ,ownname         => rec.table_owner
                                 ,partname        => rec.PARTITION_NAME
                                 ,tabname         => rec.table_name
                                 ,cascade         => true
                                 ,no_invalidate   => false
                                 ,force           => true
                                 );
    exception
    when others then
      dbms_output.put_line('Fehler bei: '||rec.table_owner||'.'||rec.table_name||' '||sqlcode||' ' || sqlerrm);
    end;
  end loop;
end;
/


