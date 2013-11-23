--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tbs.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Tablespace size information
--
--------------------------------------------------------
-- free.sql
-- usage @free <orderbycolumn>
--       @free 1
-- This SQL Plus script lists freespace by tablespace
-- Script copied from asktom.oracle.com from tom Kyte
-- Somme modifications thorsten.bruhns@opitz-consulting.de
--------------------------------------------------------
set pages 200
set lines 120

column dummy noprint
column  pct_used format 999.9       heading "%|Used"
column  name    format a16      heading "Tablespace Name"
column  Kbytes   format 9,999,999,999    heading "KBytes"
column  used    format 9,999,999,999   heading "Used"
column  free    format 9,999,999,999  heading "Free"
column  largest    format 9,999,999,999  heading "Largest"
column  max_size format 9,999,999,999 heading "MaxPoss|Kbytes"
column  pct_max_used format 999.9       heading "%|Max|Used"
break   on report

compute sum of kbytes on report
compute sum of free on report
compute sum of used on report
compute sum of max_size on report

select nvl(b.tablespace_name,
             nvl(a.tablespace_name,'UNKOWN')) name,
       kbytes_alloc kbytes,
       kbytes_alloc-nvl(kbytes_free,0) used,
       nvl(kbytes_free,0) free,
       ((kbytes_alloc-nvl(kbytes_free,0))/
                          kbytes_alloc)*100 pct_used,
--       nvl(largest,0) largest,
       nvl(kbytes_max,kbytes_alloc) Max_Size,
       ((kbytes_alloc-nvl(kbytes_free,0))/Kbytes_max*100) pct_max_used
from ( select sum(bytes)/1024 Kbytes_free,
              max(bytes)/1024 largest,
              tablespace_name
       from  sys.dba_free_space
       group by tablespace_name ) a,
     ( select sum(bytes)/1024 Kbytes_alloc,
              sum(case when maxbytes < bytes then bytes else maxbytes end)/1024 Kbytes_max,
              tablespace_name
       from sys.dba_data_files
       group by tablespace_name
       union all
      select sum(bytes)/1024 Kbytes_alloc,
              sum(case when maxbytes < bytes then bytes else maxbytes end)/1024 Kbytes_max,
              tablespace_name
       from sys.dba_temp_files
       group by tablespace_name )b
where a.tablespace_name (+) = b.tablespace_name
order by 1
/

