--
-- Thorsten Bruhns (Thorsten.Bruhns@googlemail.com)
--
-- Version: 1
-- Date   : 16.05.2021
--
--  __          __              _
--  \ \        / /             (_)
--   \ \  /\  / /_ _ _ __ _ __  _ _ __   __ _
--    \ \/  \/ / _` | '__| '_ \| | '_ \ / _` |
--     \  /\  / (_| | |  | | | | | | | | (_| |
--      \/  \/ \__,_|_|  |_| |_|_|_| |_|\__, |
--                                       __/ |
--                                      |___/
--
-- Use this script at your own risk. It could
-- damage your installation or database.

-- What does it do?
-- This script allows a clone of an existing PDB.
-- The copy of source PDB is done on OS level with
-- cp --reflink
-- The source is unplugged to create the xml for later
-- replugin of source and creation of target PDB.

-- Recommendations:
-- Datafiles for Source must be on same Filesystem as datafilepath Parameter
-- The cp --reflink needs files on same Filesystem!

-- Usage Example:
-- @pdbreflinkcopy.sql orcl /u02/reflink test01 /u02/reflink/test01

-- How does it work?
-- - switch to cdb$root
-- - source PDB: close + open read only
--   prevent structure changes on source during clone process!
-- - create spoolfile for cp --reflink
--   we need an open source PDB for spooling!
-- - source PDB: close
-- - source PDB: remove xml from previous unplug
-- - source PDB: unplug
-- - source PDB: drop + keep datafiles
-- - source PDB: plugin nocopy
-- - source PDB: open read write + save state
-- - dest PDB: create as clone from xml with source_file_directory
--   move datafiles to OMF Filenames.
-- - dest PDB: open read write+ save state

define pdbsource=&1
define xmlpath=&2
define pdbdest=&3
define datafilepath=&4

set trimspool on lines 2000 heading off echo on verify off

set time off
whenever sqlerror exit rollback
alter session set container=cdb$root;
whenever sqlerror continue none

alter  pluggable database &&pdbsource close;
whenever sqlerror exit rollback

alter  pluggable database &&pdbsource open read only;

set termout off feedback off pages 9000
set echo off

-- create cp reflink command
spool &&xmlpath/cp_reflink_&&pdbdest..sql

host test -d &&datafilepath || mkdir -p &&datafilepath

select 'host cp --reflink -p ' || FILE_NAME || ' &&datafilepath'
  from cdb_data_files cdf
  join v$containers vc on cdf.con_id = vc.con_id
 where upper(vc.name) = upper('&&pdbsource') ;

spool off
set termout on echo on

alter  pluggable database &&pdbsource close;

whenever oserror exit rollback
host rm -f &&xmlpath/cloneplug_&&pdbsource..xml
alter  pluggable database &&pdbsource unplug into '&&xmlpath/cloneplug_&&pdbsource..xml';
drop   pluggable database &&pdbsource keep datafiles;

PROMPT do reflink copy of datafiles
@@&&xmlpath/cp_reflink_&&pdbdest..sql

-- Plugin unplugged PDB
create pluggable database &&pdbsource using '&&xmlpath/cloneplug_&&pdbsource..xml' nocopy;
alter  pluggable database &&pdbsource open read write;
alter  pluggable database &&pdbsource save state;


-- Create PDB from reflink copy
create pluggable database &&pdbdest as clone using '&&xmlpath/cloneplug_&&pdbsource..xml' source_file_directory='&&datafilepath' move;
alter  pluggable database &&pdbdest open read write;
alter  pluggable database &&pdbdest save state;

whenever sqlerror continue none
whenever oserror continue none