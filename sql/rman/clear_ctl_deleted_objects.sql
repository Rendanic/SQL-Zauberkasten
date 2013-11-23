--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: clear_ctl_deleted_objects.sql 221 2010-11-01 21:33:50Z tbr $
--
-- Script for reset of control-file-pointers
--
-- Doc ID: 	465378.1 Subject: 	Rman Backup Very Slow After Mass Deletion Of Expired Backups (Disk, Tape)
-- Oracle Server - Enterprise Edition - Version: 10.2.0.2
-- 10.2.0.3 UND 10.2.0.4 sind ebenfalls betroffen!
--
prompt In Zieldatenbank:
prompt execute dbms_backup_restore.resetcfilesection(19);
prompt In RMAN-Katalog
prompt update dbinc set high_dl_recid=0;


