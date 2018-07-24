Function Get-OSServiceStudioInstallDir
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
    Get-OSServiceStudioInstallDir -MajorVersion "10.0"

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true, HelpMessage="10.0")]
        [string]$MajorVersion
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        Try{
            $output = GetServiceStudioInstallDir -MajorVersion $MajorVersion

        } Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems development environment $MajorVersion is not installed" -Exception $_.Exception
            Throw "Outsystems development environment $MajorVersion is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        Return $output
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}