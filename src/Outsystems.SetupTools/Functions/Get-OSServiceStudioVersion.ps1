function Get-OSServiceStudioVersion
{
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
    [OutputType('System.Version')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "10.0")]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    process
    {
        $output = GetServiceStudioVersion -MajorVersion $MajorVersion

        if (-not $output)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems development environment $MajorVersion is not installed"
            WriteNonTerminalError -Message "Outsystems development environment $MajorVersion is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        return [System.Version]$output
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
