--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sga_dyn_components.sql 10 2008-11-11 10:25:06Z oracle $
--
-- memory sizing for buffers in SGA
--
-- Metalink Note: 295626.1 Subject: 	How To Use Automatic Shared Memory Management (ASMM) In Oracle10g
--
set pages 100
set lines 120

column component format a30
column current_size_k format 99999999999
column min_size_k format 99999999999
column user_specified_size_k format 99999999999

select component
     , current_size/1024 current_size_k
     , min_size/1024 min_size_k
     , user_specified_size /1024 user_specified_size_k
from v$sga_dynamic_components;

 

