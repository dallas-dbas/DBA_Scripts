

SELECT 
	Getdate() as [Date],
	DB_NAME(database_id) as [DBName], 
	OBJECT_NAME(object_id) as [object name],
	OBJECT_ID, 
	avg_fragmentation_in_percent as [Fragmentation %],
	page_count,
	page_count*8/1024 as indexsizeMB,
	index_id,
	index_type_desc,
	fragment_count
	
FROM sys.dm_db_index_physical_stats (NULL, NULL, NULL, NULL, NULL) 
Where 1=1
	--and database_id =8
	--and avg_fragmentation_in_percent > 1
	and avg_fragmentation_in_percent > 4 AND page_Count > 100
	and index_id > 0
	--and DB_name(database_id) = 'Change_Me'
	--and database_id = 17
Order by page_count desc, avg_fragmentation_in_percent desc;  
GO 


