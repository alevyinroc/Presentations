use DBAThings;
declare @LatestCollection date;
declare @PreviousCollection date;

select @LatestCollection = max(CollectionDate) from auditor.PatchLevels;
set @PreviousCollection =  (select top 1 CollectionDate from (
select CollectionDate from Auditor.Patchlevels where CollectionDate < @LatestCollection) as PL order by CollectionDate desc);


--declare @TableName sysname = N'DatabaseRoleMembers';
declare @TableName sysname = N'AllPermissions';

declare @ColumnList nvarchar(max);
select @ColumnList = string_agg(quotename(c.[name]), ',') from sys.columns as C join sys.tables as T on C.object_id = T.object_id join sys.schemas as S on S.schema_id = T.schema_id
where S.[name] = N'Auditor' and T.[name] = @TableName and c.name <> N'CollectionDate';

declare @Sql nvarchar(max);

set @Sql = N'select ''Added'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam1
EXCEPT
select ''Added'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam2
UNION ALL
select ''Removed'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam2
EXCEPT
select ''Removed'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam1
;'
exec sp_executesql @sql, N'@DateParam1 date,@DateParam2 date', @LatestCollection,@PreviousCollection;