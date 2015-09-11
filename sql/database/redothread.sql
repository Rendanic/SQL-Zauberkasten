--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- 
-- Date: 12.09.2015
--
-- Details about the redo thread in all instances
-- 
--



column instance format a8
column tid format 99
column status format a10
column enabled format a10
column groups format 99

SET LINESIZE 125

SELECT INSTANCE,
       THREAD# tid,
       STATUS,
       ENABLED,
       GROUPS,
       to_char(OPEN_TIME, 'dd.mm.yy hh24:mi:ss') OPEN_TIME,
       to_char(CHECKPOINT_TIME, 'dd.mm.yy hh24:mi:ss') CHECKPOINT_TIME,
       to_char(LAST_REDO_TIME, 'dd.mm.yy hh24:mi:ss') LAST_REDO_TIME
FROM GV$THREAD
order by 1,2,3;



