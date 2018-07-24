Function Get-OSServiceStudioVersion {
    <#
    .SYNOPSIS
    Returns the Outsystems development environment installed version.

    .DESCRIPTION
    This will returns the Outsystems platform installed version. Cause you can have multiple development environments installed, you need to specify the major version.
    Will throw an exception if the platform is not installed.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10.0, 11.0, ...

    .EXAMPLE
    Get-OSServiceStudioVersion -MajorVersion "10.0"

    #>
    [CmdletBinding()]
    [OutputType([System.Version])]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "10.0")]
        [string]$MajorVersion
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        Try {
            $output = GetDevEnvVersion -MajorVersion $MajorVersion
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems development environment $MajorVersion is not installed"
            Throw "Outsystems development environment $MajorVersion is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        Return [System.Version]$output
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}