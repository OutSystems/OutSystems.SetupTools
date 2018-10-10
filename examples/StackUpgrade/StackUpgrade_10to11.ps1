param(
    [Parameter(Mandatory = $true)][ValidateSet('DC', 'FE')][string]$OSRole
)

# -- Prompt for Service Center and DB SA credentials
$SCCreds = Get-Credential -Message 'Service Center credentials'
$DBCreds = Get-Credential -Message 'Database Admin credentials'
$RabbitMQCreds = Get-Credential -Message 'RabbitMQ user credentials'

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Install-Module -Name Outsystems.SetupTools -Force -MinimumVersion 2.2.0.0 | Out-Null
Import-Module -Name Outsystems.SetupTools -MinimumVersion 2.2.0.0 -ArgumentList $true, 'UpgradeOS10to11' | Out-Null

# -- Get platform major version
$OSServerVersion = Get-OSServerVersion
if (-not $OSServerVersion) { throw "Platform not installed" }
$OSServerMajorVersion = "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)"

# -- Check if update is needed
if ($OSServerMajorVersion -ne '10.0') { throw 'Platform is not at the 10.0 version' }

# -- Before updating lets refresh outdated modules
Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Id -eq 6} -ErrorAction Stop | Publish-OSPlatformModule -Wait -Verbose -ErrorAction Stop | Out-Null

# -- And finally, lets check if the factory is consistent
if (Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Count -ne 0} -ErrorAction Stop) { throw "Factory is inconsistent. Aborting the update." }

# -- Stop OS Services for the update. Configuration tool will restart them after the update
Stop-OSServerServices -Verbose -ErrorAction Stop

# -- Install PreReqs for the new major
Install-OSServerPreReqs -MajorVersion '11.0' -Verbose -ErrorAction Stop | Out-Null

# -- Download and install OS Server
Install-OSServer -Version $(Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '11.0' -Latest) -Verbose -ErrorAction Stop | Out-Null

# -- Download and install Service Studio in the same path as the 10.0
$OSServiceStudioInstallDir = $(Get-OSServiceStudioInstallDir -MajorVersion '10.0') -replace '\Development Environment 10.0', ''
Install-OSServiceStudio -InstallDir $OSServiceStudioInstallDir -Version $(Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11.0' -Latest) -Verbose -ErrorAction Stop | Out-Null

# -- Set RabbitMQ user and pass
Set-OSServerConfig -Setting 'CacheInvalidationConfiguration/ServiceUsername' -Value $RabbitMQCreds.UserName -ErrorAction Stop -Verbose | Out-Null
Set-OSServerConfig -Setting 'CacheInvalidationConfiguration/ServicePassword' -Value $RabbitMQCreds.GetNetworkCredential().Password -Encrypted -ErrorAction Stop -Verbose | Out-Null

# -- Apply the configuration
Set-OSServerConfig -Apply -PlatformDBCredential $DBCreds -SessionDBCredential $DBCreds -LogDBCredential $DBCreds -Verbose -ErrorAction Stop | Out-Null

if ($OSRole -ne 'FE')
{
    # -- Update Service Center and System Components
    Install-OSPlatformServiceCenter -Verbose -ErrorAction Stop | Out-Null
    Publish-OSPlatformSolution -Credential $SCCreds -Solution $("$(Get-OSServerInstallDir)\System_Components.osp") -Wait -Verbose -ErrorAction Stop | Out-Null

    # -- Re-Publish needed modules
    Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Id -eq 13} -ErrorAction Stop | Publish-OSPlatformModule -Wait -Verbose -ErrorAction Stop | Out-Null
}

# -- Re-apply System tunning and security settings
Set-OSServerPerformanceTunning -Verbose -ErrorAction Stop | Out-Null
Set-OSServerSecuritySettings -Verbose -ErrorAction Stop | Out-Null
