--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: aux_stat.sql 30 2010-01-12 20:58:11Z oracle $
--
-- display system statistics
--
set lines 100
set pages 100

column sname format a20
column pname format a20
column pval1 format 999,999,999.999
column pval2 format a20

select sname
      ,pname
      ,pval1
      ,pval2
from sys.aux_stats$
;




/

