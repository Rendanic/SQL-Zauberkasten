--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 07.01.2015
--
-- How To Find Where The Memory Is Growing For A Process (Doc ID 822527.1)
--
-- detail pga information for all sessions
--


set lines 140
set verify off

COLUMN category      HEADING "Category"
COLUMN allocated     HEADING "Allocated kB"
COLUMN used_kBused_kB HEADING "Used kB"
COLUMN max_alloc_kB  HEADING "Max alloc kB"

with process_memory as
(
    select *
    from v$process_memory
)
SELECT p.pid
     , round(sum(nvl(p.allocated, 0) 
                 + nvl(s.allocated, 0) 
                 + nvl(o.allocated, 0)
                )/1024/1024) sum_MB
     , round(p.allocated/1024) pl_all_kB
     , round(p.used/1024) pl_used_kB
     , round(p.max_allocated/1024) pl_mall_kB
     , round(s.allocated/1024) sq_all_kB
     , round(s.used/1024) sq_used_kB
     , round(s.max_allocated/1024) sq_mall_kB
     , round(o.allocated/1024) ot_all_kB
     , round(o.used/1024) ot_used_kB
     , round(o.max_allocated/1024) ot_mall_kB
FROM process_memory p
join process_memory o on p.pid = o.pid
join process_memory s on p.pid = s.pid
WHERE  p.category = 'PL/SQL'
AND s.category = 'SQL'
AND o.category = 'Other'
group by p.pid, p.allocated, p.used, p.max_allocated
       , o.allocated, o.used, o.max_allocated
       , s.allocated, s.used, s.max_allocated
order by 2
;

