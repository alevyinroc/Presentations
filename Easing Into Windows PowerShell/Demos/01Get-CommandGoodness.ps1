Get-Module -ListAvailable|select-object -expandproperty name|Import-Module;

Get-Command -Type cmdlet,function,filter |
	Group-Object -Property modulename |
	Select-Object -property name,count |
	Sort-Object -property count |
	Format-Table -AutoSize;

Get-Command -CommandType cmdlet |
    select-object -property @{n="Verb";e={$_.name.split("-")[0]}} |
    Group-Object -property Verb |
    Select-Object -property Name,Count |
    Sort-Object -property count -desc |
    format-table -autosize;

get-command -CommandType cmdlet -ParameterName computername |
	sort-object -property name |
	format-table -autosize
