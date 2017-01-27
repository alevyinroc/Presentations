<#
This script demonstrates the BEGIN, PROCESS & END blocks of advanced functions which use
the pipeline. The output in BEGIN and END will only appear once.
#>
Clear-Host;
Set-StrictMode -Version latest;
function Test-Pipeline1
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("p1")]
        [int]$Param1
    )

    Begin
    {
Write-Verbose "in Begin of Test-Pipeline1";
    }
    Process
    {

Write-Verbose "Processing value $Param1 in Test-Pipeline1";
Write-Output $($Param1*2);
    }
    End
    {
    Write-Verbose "In End block of Test-Pipeline1";
    }
}

function Test-Pipeline2
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("p1")]
        [int]$Param1
    )

    Begin
    {
Write-Verbose "in Begin of Test-Pipeline2";
    }
    Process
    {

Write-Verbose "Processing value $Param1 in Test-Pipeline2";
Write-Output $($Param1 * 3);
    }
    End
    {
    Write-Verbose "In End block of Test-Pipeline2";
    }
}

Clear-Host;
$arr = @(1,2,3,4,5);
$arr | Test-Pipeline1 -verbose | Test-Pipeline2 -verbose;
