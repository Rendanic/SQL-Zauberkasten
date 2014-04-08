-- io_stats_calib.sql
-- Uwe Kuechler (uwe.kuechler@opitz-consulting.de)
--
-- Calibrate I/O stats required for auto DOP
--
-- See also: Note 1269321.1 on MOS
-- @Param 1: Number of PHYSICAL disks for datafiles
-- @Param 2: Max. latency in ms (e.g. 20)

set lines 125 pages 50000
SET SERVEROUTPUT ON
DECLARE
  lat INTEGER;
  iops INTEGER;
  mbps INTEGER;
BEGIN
  --DBMS_RESOURCE_MANAGER.CALIBRATE_IO(<NUM_DISKS>, <MAX_LATENCY>,iops, mbps, lat);
  DBMS_RESOURCE_MANAGER.CALIBRATE_IO (&1, &2, iops, mbps, lat);
  DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
  DBMS_OUTPUT.PUT_LINE ('latency = ' || lat);
  dbms_output.put_line('max_mbps = ' || mbps);
end;
/
col CALIBRATION_TIME for a30
select * from V$IO_CALIBRATION_STATUS;



prompt =====================================
prompt For manual (re-)setting of I/O stats:
prompt =====================================
prompt delete from resource_io_calibrate$
prompt /
prompt -- Set MAX_PMBPS to 200 (fast subsystem):
prompt insert into resource_io_calibrate$
prompt  (START_TIME, END_TIME, MAX_IOPS, MAX_MBPS, MAX_PMBPS, LATENCY, NUM_DISKS)
prompt   values(current_timestamp, current_timestamp, 0, 0, 200, 0, 0)
prompt /
prompt commit
prompt /
/*
For manual (re-)setting of I/O stats:
-------------------------------------
delete from resource_io_calibrate$;
-- Set MAX_PMBPS to 200 (fast subsystem):
insert into resource_io_calibrate$
values(current_timestamp, current_timestamp, 0, 0, 200, 0, 0); 
commit;
*/
