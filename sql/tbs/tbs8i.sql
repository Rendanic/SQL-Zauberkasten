--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: tbs8i.sql 10 2008-11-11 10:25:06Z oracle $
--
-- Tablespace size information 8i compatible
--
REM ####################################################################
REM                                                                   ##
REM Author: Matthias Jung                                             ##
REM Description: This scripts list the filling degrees of             ##
REM              tablespaces                                          ##
REM Date: 2007/03/14                                                  ##
REM                                                                   ##
REM last change: 2007/03/14 M. Jung - 1st. Version                    ##
REM              2007/03/16 T. Bruhns - changed mb_sum and mb_used    ##
REM                                     outer join dba_free_space     ##
REM                                                                   ##
REM ####################################################################

set pages 1000
SELECT a.tablespace_name,
  round((a.bytes-b.bytes)/1204/1024,2) mb_used,
  round(b.bytes/1024/1024,2) mb_free,
  round((a.bytes)/1024/1024,2) mb_sum,
  ROUND(((a.bytes -b.bytes) / a.bytes) * 100,   2) percent_used
FROM
  (SELECT tablespace_name,
     SUM(bytes) bytes
   FROM (select tablespace_name,bytes
           from dba_data_files
          union all
         select tablespace_name, bytes
           from dba_temp_files
       ) 
   GROUP BY tablespace_name)
a,
    (SELECT tablespace_name,
     SUM(bytes) bytes,
     MAX(bytes) largest
   FROM dba_free_space
   GROUP BY tablespace_name)
b
WHERE a.tablespace_name = b.tablespace_name (+)
ORDER BY((a.bytes -b.bytes) / a.bytes) DESC
/

