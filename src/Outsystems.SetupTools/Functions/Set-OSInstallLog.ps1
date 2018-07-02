Function Set-OSInstallLog
{
    <#
    .SYNOPSIS
    Sets the log file location.

    .DESCRIPTION
    This will set the name and location where the log file will be stored.

    .EXAMPLE
    Set-OSInstallLog -Path $ENV:Windir\temp -File Install.log

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$File
    )

    If( -not (Test-Path -Path $Path)){

        Try{
            New-Item -Path $Path -ItemType directory -Force | Out-Null
        } Catch {
            Throw "Error creating the log file location"
        }

    }

    $Script:LogFile = "$Path\$File"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "************* Starting Log **************"

}