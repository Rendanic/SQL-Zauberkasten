--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sga_heap.sql 10 2008-11-11 10:25:06Z oracle $
--
-- detail sga_heap from SGA
--
set lines 120
set pages 100

col sga_heap format a15 
col size format a10 

select KSMCHIDX "SubPool", 'sga heap('||KSMCHIDX||',0)'sga_heap,ksmchcom ChunkComment, 
decode(round(ksmchsiz/1000),0,'0-1K', 1,'1-2K', 2,'2-3K',3,'3-4K', 
4,'4-5K',5,'5-6k',6,'6-7k',7,'7-8k',8, 
'8-9k', 9,'9-10k','> 10K') "size", 
count(*),ksmchcls Status, sum(ksmchsiz) Bytes 
from x$ksmsp 
where KSMCHCOM = 'free memory' 
group by ksmchidx, ksmchcls, 
'sga heap('||KSMCHIDX||',0)',ksmchcom, ksmchcls,decode(round(ksmchsiz/1000),0,'0-1K', 
1,'1-2K', 2,'2-3K', 3,'3-4K',4,'4-5K',5,'5-6k',6, 
'6-7k',7,'7-8k',8,'8-9k', 9,'9-10k','> 10K');

