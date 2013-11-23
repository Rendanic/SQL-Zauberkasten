-- Parameter 1: db_key from rc_database
-- Parameter 2: db_id from rc_database
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: delete_db_from_rman.sql 222 2010-11-01 21:48:49Z tbr $
--
-- unregister database without deadlocks from catalog
--

begin
  -- Lock table, da sonst Deadlocks verursacht werden koennen, 
  -- wenn parallel andere Sicherungen laufen
  lock table db in exclusive mode;
  dbms_rcvcat.unregisterDatabase(db_key=> &1
                                ,db_id => &2
                                );
end;
/

