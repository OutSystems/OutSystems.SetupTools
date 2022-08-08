function Get-OSIntegrationStudioVersion
{
    <#
    .SYNOPSIS
    DEPRECATED - Use Get-OSIntegrationStudioInfo
    Returns the OutSystems Integration Studio installed version.

    .DESCRIPTION
    This will returns the OutSystems platform installed version.

    .PARAMETER MajorVersion
    Major version. 11

    .EXAMPLE
    Get-OSIntegrationStudioVersion -MajorVersion "11"

    #>
    [CmdletBinding()]
    [OutputType('System.Version')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "11")]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        $output = GetIntegrationStudioVersion -MajorVersion $MajorVersion

        if (-not $output)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems Integration Studio $MajorVersion is not installed"
            WriteNonTerminalError -Message "Outsystems Integration Studio $MajorVersion is not installed"

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