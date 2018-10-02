# --------------------------------------------------------------------------------------------------------------------
# -- OutSystems version --

# Change this variables to the desired version
$OSServerVersion='10.0.823.0'
$OSServiceStudioVersion='10.0.825.0'
# --------------------------------------------------------------------------------------------------------------------

# -- Prompt for Service Center and DB SA credentials
$SCCreds = Get-Credential -Message 'Service Center credentials'
$DBCreds = Get-Credential -Message 'Database Admin credentials'

# -- Stop script on any error
$global:ErrorActionPreference = 'Stop'

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Install-Module -Name Outsystems.SetupTools -Force | Out-Null
Import-Module -Name Outsystems.SetupTools -ArgumentList $true, 'AzureRM' | Out-Null

# -- Before updating lets refresh outdated modules
Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Id -eq 6} | Publish-OSPlatformModule -Wait -Verbose

# -- And finally, lets check if the factory is consistent
if (Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Count -ne 0})
{
    throw "Factory is inconsistent. Aborting the update."
}

# -- Stop OS Services for the update. Configuration tool will restart them after the update
Stop-OSServerServices -Verbose

# -- Install PreReqs (this is supposedly not needed since we are updating the same major)
Install-OSServerPreReqs -MajorVersion "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)" -Verbose

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $OSServerVersion -Verbose
Install-OSServiceStudio -Version $OSServiceStudioVersion -Verbose

# -- Run the configuration tool with the existing parameters
Set-OSServer -Apply -Credential $DBCreds -Verbose

# -- Update Service Center and System Components
Install-OSPlatformServiceCenter -Verbose
Publish-OSPlatformSolution -Credential $SCCreds -Solution $("$(Get-OSServerInstallDir)\System_Components.osp") -Verbose -Wait


# -- Re-apply System tunning and security settings
Set-OSServerPerformanceTunning -Verbose
Set-OSServerSecuritySettings -Verbose

# -- Re-Publish needed modules
Get-OSPlatformModules -Credential $SCCreds -PassThru -Filter {$_.StatusMessages.Id -eq 13} | Publish-OSPlatformModule -Wait -Verbose
