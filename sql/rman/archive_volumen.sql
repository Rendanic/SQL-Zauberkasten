--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: archive_volumen.sql 221 2010-11-01 21:33:50Z tbr $
--
-- archivesize per day
--

set pages 100 lines 100 trimspool on
column tag format a8
column vol_gb format 999,999.999
column comp_gb format 999,999.999

select to_char(trunc(first_time),'dd.mm.yy') tag
     , trunc(sum(filesize)/1024/1024/1024,3) vol_gb
     , trunc(sum(filesize/COMPRESSION_RATIO)/1024/1024/1024,3) comp_gb
from V$BACKUP_ARCHIVELOG_DETAILs
group by trunc(first_time)
order by trunc(first_time);

