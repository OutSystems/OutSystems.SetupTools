Function Get-OSServerInstallDir {
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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        Try {
            $output = GetServerInstallDir
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed" -Exception $_.Exception
            Throw "Outsystems platform is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        Return $output
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}