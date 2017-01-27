function Test-Parameters {
[cmdletbinding()]
param (
	[ValidateSet("dev","test","prod")]
	[string]$AppEnvironment
)

	[ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
	[ValidateRange()]
	[ValidateScript()]