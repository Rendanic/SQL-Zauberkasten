--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: delete_old_incarnation.sql 222 2010-11-01 21:48:49Z tbr $
--
-- delete backups older then 180days from catalog
--
begin
for dbinc in (select dbinc_key as this_dbinc_key
                    ,db_key as this_db_key
from rc_database_incarnation)
loop
DELETE FROM rsr
WHERE rsr_end < sysdate-180
  and dbinc_key = dbinc.this_dbinc_key 
  AND rsr_key IN (
      SELECT rsr.rsr_key
      FROM rsr LEFT OUTER JOIN bp ON bp.rsr_key = rsr.rsr_key
                AND dbinc.this_db_key = bp.db_key
      LEFT OUTER JOIN cdf ON cdf.rsr_key = rsr.rsr_key
                AND dbinc.this_dbinc_key = cdf.dbinc_key
      LEFT OUTER JOIN ccf ON ccf.rsr_key = rsr.rsr_key
                AND dbinc.this_dbinc_key = ccf.dbinc_key
      LEFT OUTER JOIN xdf ON xdf.rsr_key = rsr.rsr_key
                AND dbinc.this_dbinc_key = xdf.dbinc_key
      LEFT OUTER JOIN xcf ON xcf.rsr_key = rsr.rsr_key
                AND dbinc.this_dbinc_key = xcf.dbinc_key
      LEFT OUTER JOIN xal ON xal.rsr_key = rsr.rsr_key
                AND dbinc.this_dbinc_key = xal.dbinc_key
      WHERE bp.rsr_key is NULL
      AND cdf.rsr_key is NULL
      AND ccf.rsr_key is NULL
      AND xdf.rsr_key is NULL
      AND xcf.rsr_key is NULL
      AND xal.rsr_key is NULL)
; 
end loop;
end;
/

