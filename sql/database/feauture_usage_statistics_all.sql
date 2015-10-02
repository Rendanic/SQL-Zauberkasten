--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 02.10.2015
-- Version: 1
-- statistics information from DBA_FEATURE_USAGE_STATISTICS
-- all currently used feautures are listed
--

set lines 140 pages 100

column name format a50
column version format 9999999999
column used format a5
column last_usage format a14
column first format a8


select df.name
      ,df.version
      ,to_char(df.LAST_USAGE_DATE,'dd.mm.yy hh24:MI') last_usage
      ,to_char(df.FIRST_USAGE_DATE,'dd.mm.yy') first
from DBA_FEATURE_USAGE_STATISTICS df
join v$database vd on vd.dbid = df.dbid
order by df.name
;

