--                                                                                                                                                    
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)                                                                                              
-- $Id: create_snapshot.sql 73 2010-03-16 04:26:32Z tbr $
--                                                                                                                                                    
-- generates a Snapshot in the workload repository
--
set echo on
exec dbms_workload_repository.create_snapshot
 
