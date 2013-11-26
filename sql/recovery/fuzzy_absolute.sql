--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: fuzzy_absolute.sql 1058 2013-11-15 06:19:21Z tbr $
--
-- Unable to open the database in read only mode after restore/recovery (Doc ID 316154.1)
-- How to quickly check that Database is consistent after incomplete recovery (Point in Time Recovery) before OPEN RESETLOGS (Doc ID 1354256.1)
--
-- Display fuzzy information from x$kcvfh

set lines 140 pages 100
column fuzzy format a5
column error format a20
column chkp_change format 99999999999
column recover format a3
column name format a50
select hxfil file#
     , substr(hxfnm , 1, 50) name
     , fhscn checkpoint_change#
     , fhafs Absolute_Fuzzy_SCN
     , max(fhafs) over () Min_PIT_SCN 
  from x$kcvfh 
 where fhafs!=0 
;
