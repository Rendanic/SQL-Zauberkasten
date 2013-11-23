--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: no_bind.sql 10 2008-11-11 10:25:06Z oracle $
--
-- get SQLs without bind-variables
--
-- Original source of pl/sql block is unknown!
--
/*
SELECT substr(sql_text,1,90) "SQL",count(*) "SQL Copies", 
   sum(executions) "TotExecs", sum(sharable_mem) "TotMemory" 
FROM v$sqlarea 
WHERE executions < 5 
GROUP BY substr(sql_text,1,90) HAVING count(*) > 30 
ORDER BY 2; 
*/

set serveroutput on 
set lines 120 

declare 
  b_myadr VARCHAR2(20); 
  b_myadr1 VARCHAR2(20); 
  qstring VARCHAR2(100); 
  b_anybind NUMBER; 

cursor my_statement is 
select address from v$sql 
group by address; 

cursor getsqlcode is 
select substr(sql_text,1,60) 
from v$sql 
where address = b_myadr; 

cursor kglcur is 
select kglhdadr from x$kglcursor 
where kglhdpar = b_myadr 
and kglhdpar != kglhdadr 
and kglobt09 = 0; 

cursor isthisliteral is 
select kkscbndt 
from x$kksbv 
where kglhdadr = b_myadr1; 

begin 

	dbms_output.enable(10000000); 

	open my_statement; 
	loop 
		Fetch my_statement into b_myadr; 
		open kglcur; 
		fetch kglcur into b_myadr1; 
		if kglcur%FOUND 
		Then 
			open isthisliteral; 
			fetch isthisliteral into b_anybind; 
			if isthisliteral%NOTFOUND 
			Then 
				open getsqlcode; 
				fetch getsqlcode into qstring; 
				dbms_output.put_line('Literal:'||qstring||' address: '||b_myadr); 
					close getsqlcode; 
			end if; 
		clo	se isthisliteral; 
		end if;	 
		close kglcur; 
		Exit When my_statement%NOTFOUND; 
	End loop; 
close my_statement; 
end; 
/ 

