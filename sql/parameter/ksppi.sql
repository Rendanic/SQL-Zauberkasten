--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: ksppi.sql 93 2010-03-24 04:42:58Z tbr $
--
-- Displays information from x$ksppi (all init.ora-Parameters)
--
prompt Parameter 1: Parameter

set lines 130
set pages 100
set trimspool on
set verify off

column KSPPINM format a40
column KSPPDESC format a70

select KSPPINM
      ,ltrim(KSPPDESC) KSPPDESC
from x$ksppi
where (KSPPINM) like '&1';

