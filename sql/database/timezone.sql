--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
--
-- Date: 06.09.2023
-- Version: 1
--
-- Diesplay timezone data from database
--
set lines 120 pages 10
COLUMN property_name FORMAT A30
COLUMN property_value FORMAT A20

SELECT property_name, property_value
FROM   database_properties
WHERE  property_name LIKE 'DST_%'
ORDER BY property_name;
