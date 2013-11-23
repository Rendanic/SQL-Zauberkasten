--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: get_param.sql 10 2008-11-11 10:25:06Z oracle $
--
-- get default statistic parameter from database
--
-- Note:406475.1 Subject: 	What are default parameters when i gather statistisc on Table on 9i and 10g
-- Note:725845.1 Subject:       How to Change Default Parameters for Gathering Statistics

select dbms_stats.get_param('cascade') from dual;
select dbms_stats.get_param('degree') from dual;
select dbms_stats.get_param('estimate_percent') from dual;
select dbms_stats.get_param('method_opt') from dual;
select dbms_stats.get_param('no_invalidate') from dual;
select dbms_stats.get_param('granularity') from dual;

