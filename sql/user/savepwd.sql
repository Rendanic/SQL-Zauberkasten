--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: savepwd.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Spool  pre 11g user hash-values from dba_users
--
-- Sichert alle HASH-Werte der Datenbankuser
-- Das Ergebnis kann spaeter direkt ausgefuehrt werden, um die Passworte wieder herzustellen
--
-- Folgende bedingungen sind erforderlich:
-- 
-- Beim Einsatz von Password-Verify-Funktion muss es beim Profil DEFAULT erlaubt sein, ein beliebiges Password wieder zu verwenden
--

set trimspool on
set lines 200
set heading off

select 'alter user ' || username || ' identified by values '''||password||''' profile default;'
from dba_users;

select 'alter user ' || username || ' profile '||profile||';'
from dba_users;


