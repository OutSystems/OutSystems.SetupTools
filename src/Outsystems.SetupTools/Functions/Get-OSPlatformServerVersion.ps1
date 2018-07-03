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
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        Try {
            $output = GetServerVersion
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $output"
        Return [System.Version]$output
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}