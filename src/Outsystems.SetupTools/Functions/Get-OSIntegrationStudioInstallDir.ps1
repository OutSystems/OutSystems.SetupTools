function Get-OSIntegrationStudioInstallDir
{
    <#
    .SYNOPSIS
    DEPRECATED - Use Get-OSIntegrationStudioInfo
    Returns where the OutSystems Integration Studio is installed.

    .DESCRIPTION
    This will returns where the OutSystems Integration Studio is installed.

    .PARAMETER MajorVersion
    Major version. 11

    .EXAMPLE
    Get-OSIntegrationStudioInstallDir -MajorVersion "11"

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
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
        $output = GetIntegrationStudioInstallDir -MajorVersion $MajorVersion

        if (-not $output)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems Integration Studio $MajorVersion is not installed"
            WriteNonTerminalError -Message "Outsystems Integration Studio $MajorVersion is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        return $output
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
