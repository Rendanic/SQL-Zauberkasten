-- Parameter 1: Oracle-SessionID
--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: ash.sql 247 2010-11-23 20:12:52Z tbr $
--
-- Display Active Session History Information for given ORACLE_SID
-- 

set lines 140
set pages 100
set verify off

column event format a30
column OBJECT_NAME format a30
column cf format 999
column cb format 9999999

select  to_char(ash.sample_time, 'dd.mm.yy hh24:mi:ss') zeit                                                        
      ,ash.session_id sess
      ,ash.session_state state
      ,ash.blocking_session bsess
      ,ash.BLOCKING_SESSION_STATUS block_state
      ,ash.event
      ,o.object_name
      ,ash.CURRENT_FILE# cf
      ,ash.CURRENT_BLOCK# cb
  from (
        select *
        from(
             select *
               from V$ACTIVE_SESSION_HISTORY
              where session_id = &1
             order by sample_time desc
            )
        where rownum < 41
       ) ash
left outer join dba_objects o on o.object_id=ash.CURRENT_OBJ#
order by sample_time
;


