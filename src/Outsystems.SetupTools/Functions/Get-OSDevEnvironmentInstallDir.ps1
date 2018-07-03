Function Get-OSDevEnvironmentInstallDir
{
    <#
    .SYNOPSIS
    Returns where the Outsystems development environment is installed.

    .DESCRIPTION
    This will returns where the Outsystems development environment is installed. Cause you can have multiple development environments installed, you need to specify the major version.
    Will throw an exception if the platform is not installed.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10.0, 11.0, ...

    .EXAMPLE
    Get-OSDevEnvironmentInstallDir -MajorVersion "10.0"

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true, HelpMessage="10.0")]
        [string]$MajorVersion
    )

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        Try{
            $output = GetDevEnvInstallDir -MajorVersion $MajorVersion

        } Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems development environment $MajorVersion is not installed"
            Throw "Outsystems development environment $MajorVersion is not installed"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $output"
        Return $output
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}