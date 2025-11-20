Set-DbatoolsInsecureConnection -SessionOnly;
$AllInstances = Get-DbaRegisteredServer -SqlInstance VADER\sql22 -IncludeSelf | Select-Object -ExpandProperty ServerName;

# Collecting ErrorLog locations for your SIEM (security information and event management)
Write-Information -MessageData "Getting ErrorLog paths";
$ErrorLogPaths = Get-DbaDefaultPath -SqlInstance $AllInstances | Select-Object -Property Computername, InstanceName, SqlInstance, ErrorLog;

# Check SQL Server patches
#Update-DbaBuildReference;
Write-Information -MessageData "Checking patch levels";
$CurrentPatchLevels = Test-DbaBuild -SqlInstance $AllInstances -MaxBehind 1CU | Select-Object -Property SqlInstance, Build, BuildTarget, NameLevel, SPLevel, SPTarget, CULevel, CUTarget, MaxBehind, Compliant, KBLevel, SupportedUntil;

# Database Inventory
Write-Information -MessageData "Database Inventory";
$DatabaseInventory = Get-DbaDatabase -SqlInstance $AllInstances | Select-Object -Property SqlInstance, Name, Status, IsAccessible, Owner, SizeMB | Sort-Object SqlInstance, Name;

# Database Encryption
Write-Information -MessageData "Master DB Certs";
$MasterDBCerts = Get-DbaDbCertificate -Database master -SqlInstance $AllInstances | Where-Object { $PSItem.Name -notlike '##*' } | Select-Object -Property SqlInstance, Name, Subject, StartDate, ExpirationDate, LastBackupDate, PrivateKeyEncryptionType | Sort-Object -Property SqlInstance, Name;
Write-Information -MessageData "Database Encryption";
$DatabaseEncryption = Get-DbaDatabase -SqlInstance $AllInstances |
Select-Object -Property SqlInstance, Name, EncryptionEnabled, `
@{Name = "EncryptionType"; Expression = { $_.DatabaseEncryptionKey.EncryptionType } }, `
@{Name = "EncryptionState"; Expression = { $_.DatabaseEncryptionKey.EncryptionState } }, `
@{Name = "EncryptionAlgorithm"; Expression = { $_.DatabaseEncryptionKey.EncryptionAlgorithm } }, `
@{Name = "EncryptorName"; Expression = { $_.DatabaseEncryptionKey.EncryptorName } } | Sort-Object -Property SqlInstance, Name;

Write-Information -MessageData "Instance level security";
$InstanceLogins = Get-DbaLogin -SqlInstance $AllInstances | Select-Object -Property SqlInstance, Name, LoginType, CreateDate, LastLogin, HasAccess, IsLocked, IsDisabled | Sort-Object -Property SqlInstance, Name;
$ServerRoles = Get-DbaServerRole -SqlInstance $AllInstances | Select-Object -Property SqlInstance, Name, Owner, IsFixedRole | Sort-Object -Property SqlInstance, Name;
$ServerRoleMembers = Get-DbaServerRoleMember -SqlInstance $AllInstances | Select-Object -Property SqlInstance, Role, Name | Sort-Object -Property SqlInstance, Role, Name;

$PSDefaultParameterValues.Remove('Get-Dba*:SqlInstance');
$PSDefaultParameterValues.Remove('Select-Object:ExcludeProperty');
$PSDefaultParameterValues.Add('Get-Dba*:SqlInstance', $AllInstances);
$PSDefaultParameterValues.Add('Select-Object:ExcludeProperty', @("RowError", "RowState", "Table", "ItemArray", "HasErrors"));

Write-Information -MessageData "Database level security";
$DatabaseUsers = Get-DbaDbUser -ExcludeSystemUser | Select-Object -Property SqlInstance, Database, Name, Login, LoginType, HasDbAccess, CreateDate, DateLastModified | Sort-Object -Property SqlInstance, Database, Name;
$DatabaseRoles = Get-DbaDbRole -ExcludeFixedRole | Select-Object -Property SqlInstance, Database, Name | Sort-Object -Property SqlInstance, Database, Name;
$DatabaseRoleMembers = Get-DbaDbRoleMember | Select-Object -Property SqlInstance, Database, Role, UserName | Sort-Object -Property SqlInstance, Database, Role;

Write-Information -MessageData "All Permissions";
$AllPermissions = Get-DbaPermission -IncludeServerLevel | Select-Object -Property SqlInstance, Database, Grantee, SecurableType, Securable, PermissionName, PermState | Sort-Object -Property SqlInstance, Database, Grantee, SecurableType, Securable, PermissionName;

# Backups
Write-Information -MessageData "Last backup"
$LastBackup = Get-DbaLastBackup | Select-Object -Property SqlInstance, Database, LastFullBackup, LastDiffBackup, LastLogBackup | Sort-Object -Property SqlInstance, Database;

# Two ways to get backup history
# #1 - Get history from MSDB
Write-Information -MessageData "Backup history 1";
$MSDBBackupHistory = Get-DbaDbBackupHistory | Select-Object SqlInstance, Database, Type, Start, End | Sort-Object -Property SqlInstance, Database, Start;

# #2 - Get history from Ola's CommandLog table
Write-Information -MessageData "Backup history 2";
$BackupJobHistory = Invoke-DbaQuery -SqlInstance $AllInstances -AppendServerInstance -Database DBAthings -Query "select DatabaseName,CommandType,StartTime,EndTime,ErrorNumber,ErrorMessage from CommandLog where CommandType like 'BACKUP_%';" | Sort-Object -Property ServerInstance, DatabaseName, StartTime | Select-Object -Property *;

# Last time we did a DBCC CHECKDB?
Write-Information -MessageData "Last checkdb";
$LastGoodCheckDB = Get-DbaLastGoodCheckDb -ExcludeDatabase tempdb | Select-Object -Property SqlInstance, Database, DatabaseCreated, LastGoodCheckDb, Status | Sort-Object -Property SqlInstance, Database;

# All the DBCC CHECKDBs?
Write-Information -MessageData "All checkdbs"
$AllCheckDBs = Invoke-DbaQuery -SqlInstance $AllInstances -AppendServerInstance -Database DBAthings -Query "select DatabaseName,CommandType,StartTime,EndTime,ErrorNumber,ErrorMessage from CommandLog where CommandType = 'DBCC_CHECKDB';" | Select-Object -Property *;

# Backup tests?
Write-Information -MessageData "Database restore tests";
$BackupRestoreTests = Invoke-DbaQuery -SqlInstance $AllInstances -AppendServerInstance -Database DBAThings -Query "select SourceServer,TestServer,[Database],FileExists,Size,RestoreResult,DbccResult,RestoreStart,RestoreEnd,DbccStart,DbccEnd,BackupDates,BackupFiles from BackupTestResults order by RestoreStart" | Select-Object -Property *;

<# Run everything up to this point #>
$CollectionDate = Get-Date -Format "yyyy-MM-dd";
$AddCollectionDateParams = @{
    MemberType = 'NoteProperty';
    Name       = 'CollectionDate';
    Value      = $CollectionDate;
}
$AllInstances | Add-Member @AddCollectionDateParams;
$ErrorLogPaths | Add-Member @AddCollectionDateParams;
$CurrentPatchLevels | Add-Member @AddCollectionDateParams;
$MasterDBCerts | Add-Member @AddCollectionDateParams;
$DatabaseInventory | Add-Member @AddCollectionDateParams;
$DatabaseEncryption | Add-Member @AddCollectionDateParams;
$InstanceLogins | Add-Member @AddCollectionDateParams;
$ServerRoles | Add-Member @AddCollectionDateParams;
$ServerRoleMembers | Add-Member @AddCollectionDateParams;
$DatabaseUsers | Add-Member @AddCollectionDateParams;
$DatabaseRoles | Add-Member @AddCollectionDateParams;
$DatabaseRoleMembers | Add-Member @AddCollectionDateParams;
$AllPermissions | Add-Member @AddCollectionDateParams;
$LastBackup | Add-Member @AddCollectionDateParams;
$MSDBBackupHistory | Add-Member @AddCollectionDateParams;
$BackupJobHistory | Add-Member @AddCollectionDateParams;
$LastGoodCheckDB | Add-Member @AddCollectionDateParams;
$AllCheckDBs | Add-Member @AddCollectionDateParams;
$BackupRestoreTests | Add-Member @AddCollectionDateParams;

Write-Information -MessageData "Write results to database";
$CommonWriteParams = @{
    SqlInstance     = 'VADER\sql22'
    Database        = 'DBAThings'
    Schema          = 'Auditor'
    AutoCreateTable = $true
    Confirm         = $false
};
$AllInstances | Write-DbaDataTable @CommonWriteParams -Table SQLInstances;
$ErrorLogPaths | Write-DbaDataTable @CommonWriteParams -Table ErrorLogPaths;
$CurrentPatchLevels | Write-DbaDataTable @CommonWriteParams -Table PatchLevels;
$MasterDBCerts | Write-DbaDataTable @CommonWriteParams -Table MasterDBCertificates;
$DatabaseInventory | Write-DbaDataTable @CommonWriteParams -Table DatabaseInventory;
$DatabaseEncryption | Write-DbaDataTable @CommonWriteParams -Table DatabaseEncryption;
$InstanceLogins | Write-DbaDataTable @CommonWriteParams -Table InstanceLogins;
$ServerRoles | Write-DbaDataTable @CommonWriteParams -Table ServerRoles;
$ServerRoleMembers | Write-DbaDataTable @CommonWriteParams -Table ServerRoleMembers;
$DatabaseUsers | Write-DbaDataTable @CommonWriteParams -Table DatabaseUsers;
$DatabaseRoles | Write-DbaDataTable @CommonWriteParams -Table DatabaseRoles;
$DatabaseRoleMembers | Write-DbaDataTable @CommonWriteParams -Table DatabaseRoleMembers;
$AllPermissions | Write-DbaDataTable @CommonWriteParams -Table AllPermissions;
$LastBackup | Write-DbaDataTable @CommonWriteParams -Table LastBackups;
$MSDBBackupHistory | Write-DbaDataTable @CommonWriteParams -Table MSDBBackupHistory;
$BackupJobHistory | Write-DbaDataTable @CommonWriteParams -Table BackupJobHistory;
$LastGoodCheckDB | Write-DbaDataTable @CommonWriteParams -Table LastGoodCheckDB;
$AllCheckDBs | Write-DbaDataTable @CommonWriteParams -Table AllCheckDBs;
$BackupRestoreTests | Write-DbaDataTable @CommonWriteParams -Table BackupRestoreTests;
Write-Information -MessageData "Done writing to database";
