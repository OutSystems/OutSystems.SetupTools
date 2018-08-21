function Get-OSServerVersion {
    <#
    .SYNOPSIS
    Returns the current Outsystems platform version

    .DESCRIPTION
    This will returns the current Outsystems platform installed version. Will throw an exception if the platform is not installed.

    .EXAMPLE
    Get-OSServerVersion

    #>

    [CmdletBinding()]
    [OutputType([System.Version])]
    param ()

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    process {
        $output = GetServerVersion

        if (-not $output) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        return [System.Version]$output
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
