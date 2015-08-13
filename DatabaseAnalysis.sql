/*
    Quick Database Analysis Script
    @CheckinNuggets, 2012ish
*/
 
/* Fill temp table with RowCount Data */
CREATE TABLE #counts
(
    TableName varchar(255),
    Records int
)
 
EXEC sp_MSForEachTable @command1='INSERT #counts (TableName, Records) SELECT PARSENAME(''?'', 1), COUNT(*) FROM ?'
 
/* Tables with no PK*/
SELECT
    *
FROM
    #counts
WHERE
    TableName NOT IN
    ( 
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
    )
ORDER BY
    Records Desc
     
 
/* Tables where PK is not Integer or Guid (excluded Microsoft provided tables) */
SELECT
    col.TABLE_NAME,
    col.COLUMN_NAME,
    col.DATA_TYPE,
    c.Records
FROM
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS con
        INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON ccu.TABLE_NAME = con.TABLE_NAME and ccu.COLUMN_NAME = ccu.COLUMN_NAME
            INNER JOIN INFORMATION_SCHEMA.COLUMNS col ON ccu.TABLE_NAME = col.TABLE_NAME AND ccu.COLUMN_NAME = col.COLUMN_NAME
                LEFT JOIN #counts c ON c.TableName = col.TABLE_NAME
WHERE
    CONSTRAINT_TYPE = 'PRIMARY KEY'
    AND DATA_TYPE NOT IN ('int', 'uniqueidentifier')
    AND col.TABLE_NAME NOT LIKE 'aspnet%'
ORDER BY
    c.Records DESC
 
 
-- Tables with Composite PK, one component of which is unique
SELECT
    ccu.TABLE_NAME,
    Count(*) AS PKs,
    SUM( columnproperty(object_id(ccu.table_name), ccu.column_name,'IsIdentity') ) AS Identities,
    MIN(c.Records) AS Records -- Function irrelevant, just give me a value from the aggregate, they're all the same
FROM     
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS con ON con.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
    INNER JOIN #counts c ON c.TableName = ccu.TABLE_NAME
WHERE
    CONSTRAINT_TYPE = 'PRIMARY KEY'    
GROUP BY
    ccu.TABLE_NAME
HAVING
    COUNT(*) &gt; 1
    AND SUM( columnproperty(object_id(ccu.table_name), ccu.column_name,'IsIdentity') ) &gt; 0
ORDER BY
    MIN(c.Records) DESC    
 
-- Cleanup temp table
DROP TABLE #Counts