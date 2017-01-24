# Step through the directory structure made available by the SQL Server PSProvider

Clear-Host;
Push-location; Import-Module SQLPS; Pop-Location;

Get-PSDrive | Sort-Object -Property Provider,Name | Format-Table -AutoSize

Get-ChildItem Alias:\
Get-Alias -Name dir
Get-Alias -Definition 'Get-ChildItem'

Get-ChildItem C:\
Get-ChildItem Env:\

Get-ChildItem SQLSERVER:\
Set-Location SQLServer:\SQL\sql2014\default\databases\cachedb
Get-ChildItem
Set-Location Tables
Get-ChildItem -Force

Set-Location C:
Remove-Module SQLPS;