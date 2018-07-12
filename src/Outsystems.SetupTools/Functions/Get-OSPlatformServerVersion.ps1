Function Get-OSPlatformServerVersion {
    <#
    .SYNOPSIS
    Returns the current Outsystems platform version

    .DESCRIPTION
    This will returns the current Outsystems platform installed version. Will throw an exception if the platform is not installed.

    #>

    [CmdletBinding()]
    [OutputType([System.Version])]
    Param()

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        Try {
            $output = GetServerVersion
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        Return [System.Version]$output
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}