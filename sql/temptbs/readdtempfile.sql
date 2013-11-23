--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: readdtempfile.sql 10 2008-11-11 10:25:06Z oracle $
--
-- drop and add the given tempfile to a temp-TBS
-- only useable, when temp-TBS has more then 2 Tempfiles
--
-- Parameter 1: tempfilename
--

alter database tempfile '&1' offline;
alter tablespace temp drop tempfile '&1';
alter tablespace temp add tempfile '&1' reuse;
 

