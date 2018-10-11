---
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- Version: 0.1
-- Date: 11.10.2018
--
-- Startup Trigger for <pdb>_rw/ro services
--
-- Please make sure to register the service before.
-- Missing services will be ignored by the trigger to prevent errors in alert.log


CREATE OR REPLACE TRIGGER
   manage_service_in_pdb
after startup on database
DECLARE
   role       v$database.database_role%type;
   cdb        v$database.cdb%type;
   con_name   v$containers.name%type;
   svc_name   varchar2(500);
BEGIN
   SELECT DATABASE_ROLE, CDB INTO role, cdb FROM V$DATABASE;
   SELECT name INTO con_name FROM V$CONTAINERS;
   IF cdb = 'YES' THEN
      IF role = 'PRIMARY' THEN
         svc_name := lower(con_name || '_rw');
      ELSE
         svc_name := lower(con_name || '_ro');
      END IF;

      -- enable service only when registered
      for cur1 in (select name
                     from all_services
                    where lower(name) = svc_name) loop
         DBMS_SERVICE.START_SERVICE(svc_name, null);
      end loop;

   END IF;
END;
