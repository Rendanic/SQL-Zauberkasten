--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: pxsession.sql 96 2010-03-24 05:52:08Z tbr $
--
-- active parallel query processes
--

set lines 120
set pages 100
set trimspool on

column  sid format 99999
column  qcsid format 99999
column  degree format 999
column  req_degree format 999 

select sid, qcsid, degree, req_degree 
        from v$px_session
        order by qcsid,degree nulls first;

select distinct qcsid,degree ,req_degree
from v$px_session
where degree is not null;

