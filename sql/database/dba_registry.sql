--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: dba_registry.sql 60 2010-03-13 11:20:37Z tbr $
--
-- Displays information from dba_registry
--
set lines 120
set pages 100
column comp_name format a43
column version format a14
column modified format a20
column status format a7

select comp_name
      ,version
      ,status
      ,modified
  from DBA_REGISTRY
 order by comp_name
;
