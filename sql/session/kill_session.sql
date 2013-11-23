--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: kill_session.sql 233 2010-11-13 20:42:23Z tbr $
--
-- kills a given session
--
-- Parameter 1. SessionID
-- Parameter 2. SerialNr
--
alter system kill session '&1,&2';

