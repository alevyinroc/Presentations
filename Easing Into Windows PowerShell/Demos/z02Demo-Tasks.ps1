# Get total size of a directory & its subdirectories
# ExpandProperty lets us work with the raw value of the property, instead of an object
Clear-Host;
$TotalSize = get-childitem -path  C:\Users\andy.LEVYNETSCUS\Documents -force -recurse -File |
    Measure-Object -Property length -Sum |
    Select-Object -ExpandProperty Sum;

# Use .NET formatting and PowerShell byte conversion shortcut

"{0:N0} Bits" -f ($TotalSize*8);
"{0:N0} Bytes" -f $TotalSize;
"{0:N} KiB" -f ($TotalSize/1KB);
"{0:N3} MiB" -f ($TotalSize/1MB);
"{0:N4} GiB" -f ($TotalSize/1GB);


# Filtering example 1
# Two ways to filter Get-ADComputer

Clear-Host;
# Filter in the cmdlet
Get-ADComputer -filter "operatingsystem -like '*server*'" |
    format-table -autosize;

# Filter via Where-Object after the cmdlet returns all results
Get-ADComputer -filter * -properties operatingsystem |
    where-object {$_.operatingsystem -like '*server*'} |
    format-table -autosize;

Get-ADComputer -filter "operatingsystem -like '*server*'" -properties OperatingSystem |
    select-object -Property Name,OperatingSystem |
    format-table -autosize;


# Filtering example 2
Clear-Host;

# Get a list of all computers in Active Directory
$Computers = get-adcomputer -filter * |select-object -expandproperty name;

# Run Get-WMIObject on the local computer
Get-WMIObject -Class Win32_LogicalDisk |
    where-object {$_.DriveType -eq 3} |
    Select-Object -Property PSComputerName,DeviceId,FreeSpace |
    Format-Table -AutoSize;

# Run Get-WMIObject against all computers in AD
# Filter results to just local disks after all drives are returned by WMI
Get-WMIObject -Class Win32_LogicalDisk -ComputerName $Computers |
    where-object {$_.DriveType -eq 3} |
    Select-Object -Property PSComputerName,DeviceId,FreeSpace |
    Format-Table -AutoSize;

# Tell WMI to only return local disks
$Get-WMIObject -Class Win32_LogicalDisk -ComputerName $computers -Filter “DriveType = 3” |
    Select-Object -Property PSComputerName,DeviceId,FreeSpace |
    Format-Table -AutoSize;

# Shorthand & aliases- useful on the command line, but write everything out in full for scripts.
gwmi Win32_LogicalDisk -cn $computer -Filter “DriveType = 3” |
    select PSComputerName,DeviceId,FreeSpace |
    ft -auto;

# The above works great locally, but what if I have a real weak desktop? I can run the code on other computers and just collect the results!

invoke-command -computername $computer -scriptblock {
    Get-WMIObject -Class Win32_LogicalDisk -Filter “DriveType = 3” |
        Select-Object -Property PSComputerName,DeviceId,FreeSpace
    } |
    Format-Table -AutoSize;


Clear-Host;
$AllServers = Get-ADComputer -filter "operatingsystem -like '*server*'" |select-object -ExpandProperty Name
$AllServers;
Get-WMIObject -Class Win32_LogicalDisk -ComputerName $AllServers -Filter “DriveType = 3” |
    Select-Object -Property PSComputerName,DeviceId,FreeSpace |
    Format-Table -AutoSize;

invoke-command -computername $AllServers -scriptblock {
    Get-WMIObject -Class Win32_LogicalDisk -Filter “DriveType = 3” |
       Select-Object -Property PSComputerName,DeviceId,FreeSpace} |
       Format-Table -AutoSize;
