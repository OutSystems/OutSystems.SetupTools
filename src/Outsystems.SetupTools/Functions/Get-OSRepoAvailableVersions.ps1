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
    This can be 'PlatformServer', 'Lifetime', 'DevelopmentEnvironment', 'ServiceStudio', 'IntegrationStudio'

    .PARAMETER MajorVersion
    Specifies the platform major version
    Accepted values: 10 or 11

    .PARAMETER Latest
    If specified, will only return the latest version

    .EXAMPLE
    Get all available versions of the OutSystems 10 platform server
    Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '10'

    .EXAMPLE
    Get the latest available version of the OutSystems 11 Service Studio
    Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11' -Latest

    #>

    [CmdletBinding()]
    [OutputType('String')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('PlatformServer', 'Lifetime', 'DevelopmentEnvironment', 'ServiceStudio', 'IntegrationStudio')]
        [string]$Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0', '10', '11')]   # We changed the versioning of the product but we still support the old versioning
        [string]$MajorVersion,

        [Parameter()]
        [switch]$Latest
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Fix to support the old versioning
        $MajorVersion = $MajorVersion.Split('.')[0]
    }

    process
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Getting versions from repository"

        try
        {
            $RepoFiles = GetAzStorageFileList
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
                $AppFiles = $RepoFiles | Where-Object -FilterScript { $_ -like "PlatformServer-*" }
                $AppVersions_Strings = $AppFiles -replace 'PlatformServer-', '' -replace '.exe', ''
            }
            'Lifetime'
            {
                $AppFiles = $RepoFiles | Where-Object -FilterScript { $_ -like "LifeTimeWithPlatformServer-*" }
                $AppVersions_Strings = $AppFiles -replace 'LifeTimeWithPlatformServer-', '' -replace '.exe', ''
            }
            'DevelopmentEnvironment'
            {
                $AppFiles = $RepoFiles | Where-Object -FilterScript { $_ -like "DevelopmentEnvironment-*" }
                $AppVersions_Strings = $AppFiles -replace 'DevelopmentEnvironment-', '' -replace '.exe', ''
            }
            'ServiceStudio'
            {
                $AppFiles = $RepoFiles | Where-Object -FilterScript { $_ -like "ServiceStudio-*" }
                $AppVersions_Strings = $AppFiles -replace 'ServiceStudio-', '' -replace '.exe', ''
            }
            'IntegrationStudio'
            {
                $AppFiles = $RepoFiles | Where-Object -FilterScript { $_ -like "IntegrationStudio-*" }
                $AppVersions_Strings = $AppFiles -replace 'IntegrationStudio-', '' -replace '.exe', ''
            }
        }

        # Filter only major version and sort desc
        $AppVersions = [System.Version[]]($AppVersions_Strings | Where-Object -FilterScript { $_ -like "$MajorVersion.*" }) | Sort-Object -Descending

        if ($Latest.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning the latest version"
            return $AppVersions[0].ToString()
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($AppVersions.Count) versions"
            return $AppVersions | ForEach-Object -Process { $_.ToString() }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
