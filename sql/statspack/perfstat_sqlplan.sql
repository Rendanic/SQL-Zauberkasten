--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: perfstat_sqlplan.sql 19 2010-01-12 20:21:17Z oracle $
--
-- Display plan from statspack data
--

define dbid=&1
define begin_snap=&2
define end_snap=&3
define inst_num=&4
define old_hash_value=&5

set lines 120
set pages 2000
set trimspool on

select *
  from (select
       rpad('|'||substr(lpad(' ',1*(depth-1))||operation||
            decode(options, null,'',' '||options), 1, 32), 33, ' ')||'|'||
       rpad(decode(id, 0, '----- '||to_char(plan_hash_value)||' -----'
                     , substr(decode(substr(object_name, 1, 7), 'SYS_LE_', null, object_name)
                       ||' ',1, 20)), 21, ' ')||'|'||
       lpad(decode(cardinality,null,'  ',
                decode(sign(cardinality-1000), -1, cardinality||' ',
                decode(sign(cardinality-1000000), -1, trunc(cardinality/1000)||'K',
                decode(sign(cardinality-1000000000), -1, trunc(cardinality/1000000)||'M',
                       trunc(cardinality/1000000000)||'G')))), 7, ' ') || '|' ||
       lpad(decode(bytes,null,' ',
                decode(sign(bytes-1024), -1, bytes||' ',
                decode(sign(bytes-1048576), -1, trunc(bytes/1024)||'K',
                decode(sign(bytes-1073741824), -1, trunc(bytes/1048576)||'M',
                       trunc(bytes/1073741824)||'G')))), 6, ' ') || '|' ||
       lpad(decode(cost,null,' ',
                decode(sign(cost-10000000), -1, cost||' ',
                decode(sign(cost-1000000000), -1, trunc(cost/1000000)||'M',
                       trunc(cost/1000000000)||'G'))), 8, ' ') || '|' as "Explain plan"
          from stats$sql_plan
         where plan_hash_value in (select plan_hash_value
                                     from stats$sql_plan_usage spu
                                    where spu.snap_id   between &begin_snap and &end_snap
                                      and spu.old_hash_value  = &old_hash_value
--                                      and text_subset         = :text_subset
                                      and spu.plan_hash_value > 0
                                  )
          order by plan_hash_value, id
);
/

