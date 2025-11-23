use DBAThings;
declare @LatestCollection date;
declare @PreviousCollection date;

select @LatestCollection = max(CollectionDate) from auditor.PatchLevels;
set @PreviousCollection =  (select top 1 CollectionDate from (
select CollectionDate from Auditor.Patchlevels where CollectionDate < @LatestCollection) as PL order by CollectionDate desc);

select @PreviousCollection = min(CollectionDate) from Auditor.Patchlevels;

--select @PreviousCollection = greatest(dateadd(year, -1, getdate()),min(CollectionDate)) from Auditor.Patchlevels;

--select @previouscollection,@latestcollection
declare @TableName sysname
--set @TableName = N'DatabaseRoleMembers';
--set @TableName = N'PatchLevels';
--set @TableName = N'DatabaseEncryption';
set @TableName = N'MasterDBCertificates';
--set @TableName = N'InstanceLogins'
--set @TableName = N'AllPermissions';

declare @ColumnList nvarchar(max);
select @ColumnList = string_agg(N'isnull('+quotename(c.[name])+N','''') as '+quotename(c.[name]) + '', N',') from sys.columns as C join sys.tables as T on C.object_id = T.object_id join sys.schemas as S on S.schema_id = T.schema_id
where S.[name] = N'Auditor' and T.[name] = @TableName and c.name <> N'CollectionDate' and c.name <> 'lastlogin';

declare @Sql nvarchar(max);

set @Sql = N'select * from (select ''Added'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam1
EXCEPT
select ''Added'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam2
UNION ALL
select ''Removed'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam2
EXCEPT
select ''Removed'' as [Status],' + @ColumnList + N' from [Auditor].' + quotename(@TableName) + N' where CollectionDate = @DateParam1) as [Results] order by [Status]
;'
print @sql;
exec sp_executesql @sql, N'@DateParam1 date,@DateParam2 date', @LatestCollection,@PreviousCollection;