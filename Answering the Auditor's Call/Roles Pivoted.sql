declare @LatestCollection date;
declare @PreviousCollection date;

select @LatestCollection = max(CollectionDate) from auditor.PatchLevels;
set @PreviousCollection =  (select top 1 CollectionDate from (
select CollectionDate from Auditor.Patchlevels where CollectionDate < @LatestCollection) as PL order by CollectionDate desc);
--select @PreviousCollection = min(CollectionDate) from Auditor.Patchlevels;

declare @DateParam1 date,@DateParam2 date;
set @DateParam1 = @LatestCollection;
set @DateParam2 = @PreviousCollection;;

-- Created by GitHub Copilot in SSMS - review carefully before executing
WITH Diff AS (
    select 'Added'   as [Status],
           isnull([SqlInstance],'') as SqlInstance,
           isnull([Database],'')    as DatabaseName,
           isnull([Role],'')        as RoleName,
           isnull([UserName],'')    as UserName
    from [Auditor].[DatabaseRoleMembers] where CollectionDate = @DateParam1
    EXCEPT
    select 'Added'   as [Status],
           isnull([SqlInstance],'') as SqlInstance,
           isnull([Database],'')    as DatabaseName,
           isnull([Role],'')        as RoleName,
           isnull([UserName],'')    as UserName
    from [Auditor].[DatabaseRoleMembers] where CollectionDate = @DateParam2

    UNION ALL

    select 'Removed' as [Status],
           isnull([SqlInstance],'') as SqlInstance,
           isnull([Database],'')    as DatabaseName,
           isnull([Role],'')        as RoleName,
           isnull([UserName],'')    as UserName
    from [Auditor].[DatabaseRoleMembers] where CollectionDate = @DateParam2
    EXCEPT
    select 'Removed' as [Status],
           isnull([SqlInstance],'') as SqlInstance,
           isnull([Database],'')    as DatabaseName,
           isnull([Role],'')        as RoleName,
           isnull([UserName],'')    as UserName
    from [Auditor].[DatabaseRoleMembers] where CollectionDate = @DateParam1
)
SELECT
    ISNULL([Added], '')   AS [Added],
    ISNULL([Removed], '') AS [Removed]
FROM (
    -- build a single detail string per row
    SELECT [Status],
           SqlInstance,
           DatabaseName,
           RoleName,
           UserName,
           SqlInstance + ' | ' + DatabaseName + ' | ' + RoleName + ' | ' + UserName AS Details
    FROM Diff
) s
PIVOT (
    MAX(Details) FOR [Status] IN ([Added], [Removed])
) p
ORDER BY ISNULL([Added],''), ISNULL([Removed],'');