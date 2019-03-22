--
-- Thorsten Bruhns (thorsten.bruhns@googlemail.com)
-- Thanks to Fritz Hoogland for the idea.
--
-- Date: 22.03.2019
--
-- Thanks to Fritz Hoogland for the idea.
-- Show Details about the SCN scheme:
-- https://fritshoogland.wordpress.com/2018/07/29/all-about-scns-headroom-and-mandatory-patching-before-june-2019/
--

col "RSL scheme 1" format 9,999,999,999,999,999
col "current value" format 9,999,999,999,999,999
select current_scn "SCN current value",
       ((((to_number(to_char(sysdate,'YYYY'))-1988)*12*31*24*60*60) +
       ((to_number(to_char(sysdate,'MM'))-1)*31*24*60*60) +
       (((to_number(to_char(sysdate,'DD'))-1))*24*60*60) +
       (to_number(to_char(sysdate,'HH24'))*60*60) +
       (to_number(to_char(sysdate,'MI'))*60) +
       (to_number(to_char(sysdate,'SS')))) * (16*1024)) "RSL scheme 1",
       round(current_scn /((((to_number(to_char(sysdate,'YYYY'))-1988)*12*31*24*60*60) +
       ((to_number(to_char(sysdate,'MM'))-1)*31*24*60*60) +
       (((to_number(to_char(sysdate,'DD'))-1))*24*60*60) +
       (to_number(to_char(sysdate,'HH24'))*60*60) +
       (to_number(to_char(sysdate,'MI'))*60) +
       (to_number(to_char(sysdate,'SS')))) * (16*1024))*100,5) "% to RSL scheme 1"
from v$database;
