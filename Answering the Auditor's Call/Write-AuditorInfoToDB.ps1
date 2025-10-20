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
$CollectionDate = Get-Date -Date "2025-10-20" -Format "yyyy-MM-dd";
# $CollectionDate = Get-Date -Format "yyyy-MM-dd";

$AllInstances | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$ErrorLogPaths | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$CurrentPatchLevels | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$MasterDBCerts | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$DatabaseInventory | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$DatabaseEncryption | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$InstanceLogins | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$ServerRoles | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$ServerRoleMembers | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$DatabaseUsers | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$DatabaseRoles | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$DatabaseRoleMembers | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$AllPermissions | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$LastBackup | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$MSDBBackupHistory | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$BackupJobHistory | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$LastGoodCheckDB | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$AllCheckDBs | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;
$BackupRestoreTests | Add-Member -Name CollectionDate -Value $CollectionDate -MemberType NoteProperty;

Write-Information -MessageData "Write results to database";
$AllInstances | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table SQLInstances -AutoCreateTable -Confirm:$false;
$ErrorLogPaths | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table ErrorLogPaths -AutoCreateTable -Confirm:$false;
$CurrentPatchLevels | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table PatchLevels -AutoCreateTable -Confirm:$false;
$MasterDBCerts | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table MasterDBCertificates -AutoCreateTable -Confirm:$false;
$DatabaseInventory | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table DatabaseInventory -AutoCreateTable -Confirm:$false;
$DatabaseEncryption | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table DatabaseEncryption -AutoCreateTable -Confirm:$false;
$InstanceLogins | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table InstanceLogins -AutoCreateTable -Confirm:$false;
$ServerRoles | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table ServerRoles -AutoCreateTable -Confirm:$false;
$ServerRoleMembers | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table ServerRoleMembers -AutoCreateTable -Confirm:$false;
$DatabaseUsers | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table DatabaseUsers -AutoCreateTable -Confirm:$false;
$DatabaseRoles | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table DatabaseRoles -AutoCreateTable -Confirm:$false;
$DatabaseRoleMembers | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table DatabaseRoleMembers -AutoCreateTable -Confirm:$false;
$AllPermissions | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table AllPermissions -AutoCreateTable -Confirm:$false;
$LastBackup | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table LastBackups -AutoCreateTable -Confirm:$false;
$MSDBBackupHistory | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table MSDBBackupHistory -AutoCreateTable -Confirm:$false;
$BackupJobHistory | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table BackupJobHistory -AutoCreateTable -Confirm:$false;
$LastGoodCheckDB | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table LastGoodCheckDB -AutoCreateTable -Confirm:$false;
$AllCheckDBs | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table AllCheckDBs -AutoCreateTable -Confirm:$false;
$BackupRestoreTests | Write-DbaDataTable -SqlInstance VADER\sql22 -Database DBAThings -Schema Auditor -Table BackupRestoreTests -AutoCreateTable -Confirm:$false;
Write-Information -MessageData "Done writing to database";
