
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)

-- thanks to Borys Neselovskyi for this SQL
-- the real writer of this statement is unknown.

-- Date 24.03.2015
--
-- List usage in Diskgroup for given Database. '%' can be used
--
-- Parameter 1: Diskgroup
-- Parameter 2: DB_NAME


col gname form a10
col dbname form a10
col file_type form a17
set trimspool on lines 120 pages 100 verify off
 
SELECT
    gname,
    dbname,
    file_type,
    round(SUM(space)/1024/1024) mb,
    round(SUM(space)/1024/1024/1024) gb,
    COUNT(*) "#FILES"
FROM
    (
        SELECT
            gname,
            regexp_substr(full_alias_path, '[[:alnum:]_]*',1,4) dbname,
            file_type,
            space,
            aname,
            system_created,
            alias_directory
        FROM
            (
                SELECT
                    concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path,
                    system_created,
                    alias_directory,
                    file_type,
                    space,
                    level,
                    gname,
                    aname
                FROM
                    (
                        SELECT
                            b.name            gname,
                            a.parent_index    pindex,
                            a.name            aname,
                            a.reference_index rindex ,
                            a.system_created,
                            a.alias_directory,
                            c.type file_type,
                            c.space
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b,
                            v$asm_file c
                        WHERE
                            a.group_number = b.group_number
                        AND a.group_number = c.group_number(+)
                        AND a.file_number = c.file_number(+)
                        AND a.file_incarnation = c.incarnation(+) ) START WITH (mod(pindex, power(2, 24))) = 0
                AND rindex IN
                    (
                        SELECT
                            a.reference_index
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b
                        WHERE
                            a.group_number = b.group_number
                        AND b.name like '&1'
                        AND (
                                mod(a.parent_index, power(2, 24))) = 0
                            and a.name like '&2'
                    ) CONNECT BY prior rindex = pindex )
        WHERE
            NOT file_type IS NULL
            and system_created = 'Y' )
WHERE
    dbname like '&2'
GROUP BY
    gname,
    dbname,
    file_type
ORDER BY
    gname,
    dbname,
    file_type
/

