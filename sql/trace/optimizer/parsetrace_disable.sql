--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id$
--
-- Disables Optimizer Trace for the given Session
--
-- Metalink Note: 225598.1 How to Obtain Tracing of Optimizer Computations (EVENT 10053)

PROMPT Parameter 1: SID
PROMPT Parameter 2: Serial-Nr

begin
  dbms_system.set_ev(&1,&2,10053,0,'');
end;
/

