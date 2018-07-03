Function Get-OSPlatformServerInstallDir {
    <#
    .SYNOPSIS
    Returns where the Outsystems platform server is installed.

    .DESCRIPTION
    This will returns where the Outsystems platform server is installed. Will throw an exception if the platform is not installed.

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        Try {
            $output = GetServerInstallDir
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $output"
        Return $output
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}