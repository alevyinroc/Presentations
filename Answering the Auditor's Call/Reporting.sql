use DBAThings;
declare @LatestCollection date;
declare @PreviousCollection date;

select @LatestCollection = max(CollectionDate) from auditor.PatchLevels;
set @PreviousCollection =  (select top 1 CollectionDate from (
select CollectionDate from Auditor.Patchlevels where CollectionDate < @LatestCollection) as PL order by CollectionDate desc);


declare @TableName sysname = 'DatabaseRoleMembers';

declare @ColumnList nvarchar(max);
select @ColumnList = string_agg(quotename(c.[name]), ',') from sys.columns as C join sys.tables as T on C.object_id = T.object_id join sys.schemas as S on S.schema_id = T.schema_id
where S.[name] = 'Auditor' and T.[name] = @TableNAme and c.name <> 'CollectionDate';

declare @Sql nvarchar(max);

set @Sql = N'select ' + @ColumnList + N' from [Auditor].' + @TableName + N' where CollectionDate = @DateParam1
EXCEPT
select ' + @ColumnList + N' from [Auditor].' + @TableName + N' where CollectionDate = @DateParam2;'

select 'Added between ' + cast(@PreviousCollection as char(10)) + ' and ' + cast(@LatestCollection as char(10)) as [Reviewing];
exec sp_executesql @sql, N'@DateParam1 date,@DateParam2 date', @LatestCollection,@PreviousCollection;
select 'Removed between ' + cast(@PreviousCollection as char(10)) + ' and ' + cast(@LatestCollection as char(10)) as [Reviewing];
exec sp_executesql @sql, N'@DateParam1 date,@DateParam2 date', @PreviousCollection,@LatestCollection;