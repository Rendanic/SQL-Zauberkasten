--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 25.09.2015
--
-- Tablespace usage with PDB information
-- This is only useable from 12c onwards
--
--------------------------------------------------------
set pages 200
set lines 140

column dummy noprint
column  pct_used format 999.9       heading "%|Used"
column  pdb    format a16      heading "PDB Name"
column  cdb_name format a16      heading "Tablespace Name"
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

select nvl(c.name, 'CDB$ROOT')  pdb,
       nvl(b.tablespace_name,
             nvl(a.tablespace_name,'UNKOWN')) name,
       kbytes_alloc kbytes,
       kbytes_alloc-nvl(kbytes_free,0) used,
       nvl(kbytes_free,0) free,
       ((kbytes_alloc-nvl(kbytes_free,0))/
                          kbytes_alloc)*100 pct_used,
       nvl(kbytes_max,kbytes_alloc) Max_Size,
       ((kbytes_alloc-nvl(kbytes_free,0))/Kbytes_max*100) pct_max_used
from ( select sum(bytes)/1024 Kbytes_free,
              max(bytes)/1024 largest,
              tablespace_name,
              con_id
       from  cdb_free_space
       group by tablespace_name, con_id ) a,
     ( select sum(bytes)/1024 Kbytes_alloc,
              sum(case when maxbytes < bytes then bytes else maxbytes end)/1024 Kbytes_max,
              tablespace_name,
              con_id
       from cdb_data_files
       group by tablespace_name, con_id
       union all
      select sum(bytes)/1024 Kbytes_alloc,
              sum(case when maxbytes < bytes then bytes else maxbytes end)/1024 Kbytes_max,
              tablespace_name,
              con_id
       from cdb_temp_files
       group by tablespace_name, con_id )b,
     v$pdbs c
where a.tablespace_name (+) = b.tablespace_name
  and a.con_id (+) = b.con_id
  and b.con_id = c.con_id (+)
order by 1,2
/

