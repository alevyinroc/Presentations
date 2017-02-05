import-module sqlserver;

$SQLInstance = "planex\sql2016";
$Database = "CacheDB";

$DisabledVowelCachesQuery = @'
select s.statusname,c.cachestatus,c.cacheid,c.cachename,c.created,c.lastupdated
from caches c join statuses s on c.cachestatus = s.statusid
where
	c.cachename like '[$aeiou]%'
	and  year(c.created) = year(c.lastupdated) and year(lastupdated) <= 2014 and s.statusname = 'Disabled';
;
'@
$DisabledCaches = Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query $DisabledVowelCachesQuery;
#$DisabledCaches | Format-Table -AutoSize

$SetCachesAsDisabledQuery = @'
begin transaction
update c set c.cachestatus = 2 output deleted.cacheid
	from caches c join statuses s on c.cachestatus = s.statusid where c.cachename like '[$aeiou]%'
	and  year(c.created) = year(c.lastupdated) and year(lastupdated) <= 2014 and s.statusname = 'Disabled'	
rollback transaction
'@;
Write-Output "Invoke-SqlCmd method";
$UpdatedCaches = Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query $SetCachesAsDisabledQuery;
$UpdatedCaches | Format-Table -AutoSize;

Write-Output "`n`nADO.NET method";
$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
$DBCSBuilder['Data Source'] = $SQLInstance;
$DBCSBuilder['Initial Catalog'] = $Database;
$DBCSBuilder['Integrated Security'] = "true";
$DBConnection.ConnectionString = $DBCSBuilder.ToString();
$DBConnection.Open();
$UpdateCmd = $DBConnection.CreateCommand();
$UpdateCmd.CommandText = $SetCachesAsDisabledQuery;
$UpdateCmd.Prepare();
$DataTable = New-Object System.Data.DataTable;
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;

#In a regular update query, this would be UpdateCommand()
$SqlAdapter.SelectCommand = $UpdateCmd;
$RowsUpdated = $sqlAdapter.Fill($DataTable);
$DBConnection.Close();
$DataTable|Format-Table -AutoSize;