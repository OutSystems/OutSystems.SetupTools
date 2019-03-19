function Get-OSServiceStudioInfo
{
    <#
    .SYNOPSIS
    Returns where the OutSystems Service Studio install location and version.

    .DESCRIPTION
    This will returns where the OutSystems Service Studio install location and version.
    Since we can have multiple development environments installed, you need to specify the major version to get.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10.0, 11.0, ...

    .EXAMPLE
    Get-OSServiceStudioInfo -MajorVersion "10.0"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.ServiceStudioInfo')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "10.0")]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $serviceStudioInfo = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.ServiceStudioInfo'
            InstallDir   = ''
            Version      = ''
        }
    }

    process
    {
        $serviceStudioInfo.InstallDir = GetServiceStudioInstallDir -MajorVersion $MajorVersion
        $serviceStudioInfo.Version = GetServiceStudioVersion -MajorVersion $MajorVersion

        if ($(-not $serviceStudioInfo.Version) -or $(-not $serviceStudioInfo.InstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems development environment $MajorVersion is not installed"
            WriteNonTerminalError -Message "Outsystems development environment $MajorVersion is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Studio InstallDir is: $($serviceStudioInfo.InstallDir)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Studio is: $($serviceStudioInfo.Version)"

        return $serviceStudioInfo
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
