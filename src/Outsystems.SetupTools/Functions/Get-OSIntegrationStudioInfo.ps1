function Get-OSIntegrationStudioInfo
{
    <#
    .SYNOPSIS
    Returns where the OutSystems Integration Studio install location and version.

    .DESCRIPTION
    This will return the OutSystems Integration Studio install location and version.

    .PARAMETER MajorVersion
    Major version

    .EXAMPLE
    Get-OSIntegrationStudioInfo -MajorVersion "11"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.IntegrationStudioInfo')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "11")]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $integrationStudioInfo = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.IntegrationStudioInfo'
            InstallDir   = ''
            Version      = ''
        }
    }

    process
    {
        $integrationStudioInfo.InstallDir = GetIntegrationStudioInstallDir -MajorVersion $MajorVersion
        $integrationStudioInfo.Version = GetIntegrationStudioVersion -MajorVersion $MajorVersion

        if ($(-not $integrationStudioInfo.Version) -or $(-not $integrationStudioInfo.InstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems Integration Studio $MajorVersion is not installed"
            WriteNonTerminalError -Message "OutSystems Integration Studio $MajorVersion is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Integration Studio InstallDir is: $($integrationStudioInfo.InstallDir)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Integration Studio is: $($integrationStudioInfo.Version)"

        return $integrationStudioInfo
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
