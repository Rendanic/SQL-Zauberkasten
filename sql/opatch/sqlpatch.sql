--
-- Date: 14.07.2016
-- Version: 1
--
-- get insalled Patches from ORACLE_HOME+Database
--
-- Thanks to Simon Pane for the nice article on pythian.
-- https://www.pythian.com/blog/oracle-database-12c-patching-dbms_qopatch-opatch_xml_inv-and-datapatch


set lines 145 pages 100

column PATCH_ID format 99999999
column PATCH_UID format 99999999
column DESCRIPTION format a80
column status format a10 
column SQLP format a5
column bundle format a6
column ROLLB format a5

with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
   select x.patch_id
        , x.patch_uid
        , x.rollbackable rollb
        , s.status
        , s.bundle_series bundle
        , x.description
     from a,
          xmltable('InventoryInstance/patches/*'
             passing a.patch_output
             columns
                patch_id number path 'patchID',
                patch_uid number path 'uniquePatchID',
                description varchar2(80) path 'patchDescription',
                applied_date varchar2(19) path 'appliedDate',
                rollbackable varchar2(8) path 'rollbackable'
          ) x,
          dba_registry_sqlpatch s
    where x.patch_id = s.patch_id
      and x.patch_uid = s.patch_uid
    order by applied_date;


