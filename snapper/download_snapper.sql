SET LINES 10000 TRIMSPOOL ON TRIMOUT ON PAGESIZE 0 LONG 99999999 LONGCHUNKSIZE 99999999 FEEDBACK OFF HEAD OFF
SPOOL snapper.sql
select httpuritype('http://blog.tanelpoder.com/files/scripts/snapper.sql').getCLOB() from dual;
exit

