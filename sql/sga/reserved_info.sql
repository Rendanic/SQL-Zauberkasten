--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: reserved_info.sql 10 2008-11-11 10:25:06Z oracle $
--
-- overall statistics from shared_pool
--


set lines 120

column req format 9999999
column frecnt format 999999
column usecnt format 999999
column avg_used format 99999999

select p.free_space
     , p.avg_free_size avgfsize
     , p.free_count frecnt
     , p.max_free_size maxfsize
     , p.used_space usespace
     , round(p.avg_used_size) avg_used
     , p.used_count usecnt
     , p.max_used_size musedsize
     , s.requests req
     , s.request_misses req_mis
     , s.last_miss_size mis_size
     , s.max_miss_size ma_mis_size
  from (select avg(x$ksmspr.inst_id) inst_id, 
  sum(decode(ksmchcls,'R-free',ksmchsiz,0)) free_space,
  avg(decode(ksmchcls,'R-free',ksmchsiz,0)) avg_free_size,
  sum(decode(ksmchcls,'R-free',1,0)) free_count,
  max(decode(ksmchcls,'R-free',ksmchsiz,0)) max_free_size,
  sum(decode(ksmchcls,'R-free',0,ksmchsiz)) used_space,
  avg(decode(ksmchcls,'R-free',0,ksmchsiz)) avg_used_size,  
  sum(decode(ksmchcls,'R-free',0,1)) used_count,
  max(decode(ksmchcls,'R-free',0,ksmchsiz)) max_used_size 
  from x$ksmspr
 where ksmchcom not like '%reserved sto%') p,
    (select sum(kghlurcn) requests, sum(kghlurmi) request_misses, 
    max(kghlurmz) last_miss_size, max(kghlurmx) max_miss_size, 
    sum(kghlunfu) request_failures, max(kghlunfs) last_failure_size,
    max(kghlumxa) aborted_request_threshold, sum(kghlumer) aborted_requests,
    max(kghlumes) last_aborted_size from x$kghlu) s;


select p.inst_id
     , p.free_space
     , p.avg_free_size
     , p.free_count
     , s.request_failures req_failures
     , s.last_failure_size last_fail_size
     , s.aborted_request_threshold abort_req_thres
     , s.aborted_requests abort_re
     , s.last_aborted_size last_size
  from (select avg(x$ksmspr.inst_id) inst_id, 
  sum(decode(ksmchcls,'R-free',ksmchsiz,0)) free_space,
  avg(decode(ksmchcls,'R-free',ksmchsiz,0)) avg_free_size,
  sum(decode(ksmchcls,'R-free',1,0)) free_count,
  max(decode(ksmchcls,'R-free',ksmchsiz,0)) max_free_size,
  sum(decode(ksmchcls,'R-free',0,ksmchsiz)) used_space,
  avg(decode(ksmchcls,'R-free',0,ksmchsiz)) avg_used_size,  
  sum(decode(ksmchcls,'R-free',0,1)) used_count,
  max(decode(ksmchcls,'R-free',0,ksmchsiz)) max_used_size from x$ksmspr
  where ksmchcom not like '%reserved sto%') p,
    (select sum(kghlurcn) requests, sum(kghlurmi) request_misses, 
    max(kghlurmz) last_miss_size, max(kghlurmx) max_miss_size, 
    sum(kghlunfu) request_failures, max(kghlunfs) last_failure_size,
    max(kghlumxa) aborted_request_threshold, sum(kghlumer) aborted_requests,
    max(kghlumes) last_aborted_size from x$kghlu) s;
