# List all computers in AD
get-adcomputer -filter *;

# Collect all computer names into an array
$servers = get-adcomputer -filter * | select-object -expandproperty name;
write-output $servers;

# Buh-Bye!
stop-computer -computername $servers;