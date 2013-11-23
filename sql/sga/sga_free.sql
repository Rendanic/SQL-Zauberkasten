--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: sga_free.sql 10 2008-11-11 10:25:06Z oracle $
--
-- freeable memory in SGA
--
prompt R-free                   Reserved List
prompt R-freea                  Reserved List
prompt free                     Free Memory 
prompt freeabl                  Memory for user/system processing 
prompt perm                     Memory allocated to the system 
prompt recr                     Memory for user/system processing 

SELECT KSMCHCLS CLASS
     , COUNT(KSMCHCLS) NUM
	 , SUM(KSMCHSIZ) SIZ
	 , To_char( ((SUM(KSMCHSIZ)/COUNT(KSMCHCLS)/1024)),'999,999.00')||'k' "AVG SIZE" 
FROM X$KSMSP 
GROUP BY KSMCHCLS; 

