import-module dbatools;
$ServerToCheck = 'YOURSERVER';

# Although we really should use Find-DbaDbUnusedIndex instead...

$IndexSearchQuery = @"
SELECT TOP 50
	Db_Name(DB_ID()) as [Database]
	,o.name AS [Table]
	, i.name AS IndexName
	, i.index_id AS IndexID
	, dm_ius.user_seeks AS UserSeek
	, dm_ius.user_scans AS UserScans
	, dm_ius.user_lookups AS UserLookups
	, dm_ius.user_updates AS UserUpdates
	, p.TableRows
	, ''DROP INDEX '' + QUOTENAME(i.name)
	+ '' ON '' + QUOTENAME(s.name) + ''.''
	+ QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS ''drop statement''
FROM sys.dm_db_index_usage_stats dm_ius
	INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id 
		AND dm_ius.OBJECT_ID = i.OBJECT_ID
	INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
	INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
	INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
				FROM sys.partitions p 
				GROUP BY p.index_id, p.OBJECT_ID) p
		ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE 
	OBJECTPROPERTY(dm_ius.OBJECT_ID,''IsUserTable'') = 1
	AND dm_ius.database_id = DB_ID()
	AND i.type_desc = ''nonclustered''
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
	--AND o.name in (''CloverSummary'')
ORDER BY 
	(dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
"@;
$UnusedIndexes = Get-DbaDatabase -SqlInstance $ServerToCheck -ExcludeSystem | ForEach-Object { Invoke-DbaQuery -SqlInstance $ServerToCheck -Database $PSItem -Query $IndexSearchQuery };
$UnusedIndexes|Select-Object -Property Database,Table,IndexName;