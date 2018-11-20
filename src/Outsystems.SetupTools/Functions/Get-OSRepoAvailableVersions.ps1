function Get-OSRepoAvailableVersions
{
    <#
    .SYNOPSIS
    Lists the available OutSystems applications versions available in the online repository

    .DESCRIPTION
    This will list the available OutSystems applications versions available in the online repository
    Usefull for the Install-OSServer and Install-OSServiceStudio cmdLets

    .PARAMETER Application
    Specifies which application to retrieve the version
    This can be 'PlatformServer', 'ServiceStudio', 'Lifetime'

    .PARAMETER MajorVersion
    Specifies the platform major version
    Accepted values: 10.0 or 11.0

    .PARAMETER Latest
    If specified, will only return the latest version

    .EXAMPLE
    Get all available versions of the OutSystems 10 platform server
    Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '10.0'

    .EXAMPLE
    Get the latest available version of the OutSystems 11 development environment
    Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11.0' -Latest

    #>

    [CmdletBinding()]
    [OutputType('String')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('PlatformServer', 'ServiceStudio', 'Lifetime')]
        [string]$Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0')]
        [string]$MajorVersion,

        [Parameter()]
        [switch]$Latest
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Getting versions from repository"

        try
        {
            $files = GetAzStorageFileList
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting $Application versions from repository" -Exception $_.Exception
            WriteNonTerminalError -Message "Error getting $Application versions from repository"

            return $null
        }

        # Remove the installer name from the filename
        switch ($Application)
        {
            'PlatformServer'
            {
                $versions = $files -replace 'PlatformServer-', '' -replace '.exe',''
            }
            'ServiceStudio'
            {
                $versions = $files -replace 'DevelopmentEnvironment-', '' -replace '.exe',''
            }
            'Lifetime'
            {
                $versions = $files -replace 'LifeTimeWithPlatformServer-', '' -replace '.exe',''
            }
        }

        # Filter only major version and sort desc
        [Array]$versions = $versions | Where-Object -FilterScript { $_ -like "$MajorVersion*" } | Sort-Object -Descending

        if ($Latest.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning the latest version"
            return $versions[0]
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($versions.Count) versions"
            return $versions
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
