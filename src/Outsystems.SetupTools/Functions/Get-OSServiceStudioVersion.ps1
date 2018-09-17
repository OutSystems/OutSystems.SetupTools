function Get-OSServiceStudioVersion
{
    <#
    .SYNOPSIS
    Returns the OutSystems development environment (Service Studio) installed version.

    .DESCRIPTION
    This will returns the OutSystems platform installed version.
    Since we can have multiple development environments installed, you need to specify the major version to get.

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
        SendFunctionStartEvent -InvocationInfo $MyInvocation
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
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
