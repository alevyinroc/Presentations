get-help;

Get-Command;

Get-Help Get-Command -Online;

Get-Verb;

Get-ChildItem | Get-Member;

# List of modules
Get-Module -ListAvailable;

import-module SQLPS;
get-command -module SQLPS;

# Which cmdlets support remoting?
get-command -CommandType cmdlet -ParameterName computername |
	sort-object -property name |
	format-table -autosize

# Verb Usage
Get-Command -CommandType cmdlet |
    select-object -property @{n="Verb";e={$_.name.split("-")[0]}} |
    Group-Object -property Verb |
    Select-Object -property Name,Count |
    Sort-Object -property count |
    format-table -autosize;

# List all computers in AD
get-adcomputer -filter *;

# Collect all computer names into an array
$servers = get-adcomputer -filter * | select-object -expandproperty name;
write-output $servers;

# Shut down all computers in the domain (collected above)
# DO NOT DO THIS ON A PRODUCTION NETWORK
# stop-computer -computername $servers -whatif;