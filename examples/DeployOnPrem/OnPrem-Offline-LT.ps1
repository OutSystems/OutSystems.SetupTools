[CmdletBinding()]
param(
    [Parameter()]
    [string]$InstallDir = $("$env:ProgramFiles\OutSystems")
)

# -- Stop on any error
$ErrorActionPreference = 'Stop'

# -- Import configuration file
$OfflineConfiguration = Import-Clixml "$PSScriptRoot\Configuration.xml"
$majorVersion = "$($([version]$OfflineConfiguration.LifetimeVersion).Major)"

# -- Import module from local folder
Import-Module -Name "$PSScriptRoot\Modules\AzureRM.profile" | Out-Null
Import-Module -Name "$PSScriptRoot\Modules\Azure.Storage" | Out-Null
Import-Module -Name "$PSScriptRoot\Modules\AzureRM.Storage" | Out-Null
Import-Module -Name "$PSScriptRoot\Modules\Outsystems.SetupTools" | Out-Null

# -- Check HW and OS for compability
Test-OSServerHardwareReqs -MajorVersion $majorVersion -Verbose -ErrorAction Stop | Out-Null
Test-OSServerSoftwareReqs -MajorVersion $majorVersion -Verbose -ErrorAction Stop | Out-Null

# -- Install PreReqs
$result = Install-OSServerPreReqs -MajorVersion $MajorVersion -SourcePath "$PSScriptRoot\PreReqs" -Verbose -ErrorAction Stop
if ($result.RebootNeeded)
{
    Write-Warning -Message "OutSystems pre-requisites installed but a reboot is needed. Reboot the machine and then re-run this script!!"
    exit 3010
}

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $OfflineConfiguration.LifetimeVersion -InstallDir $InstallDir -SourcePath "$PSScriptRoot\Sources" -WithLifetime -Verbose -ErrorAction Stop | Out-Null
Install-OSServiceStudio -Version $OfflineConfiguration.ServiceStudioVersion -InstallDir $InstallDir -SourcePath "$PSScriptRoot\Sources" -Verbose -ErrorAction Stop | Out-Null

# Start configuration tool
Write-Output "Launching the configuration tool... "
& "$InstallDir\Platform Server\ConfigurationTool.exe"
[void](Read-Host 'Configure the platform and press Enter to continue the OutSystems setup...')

# -- Install service center and publish system components
Install-OSPlatformServiceCenter -Verbose -ErrorAction Stop | Out-Null
Publish-OSPlatformSystemComponents -Verbose -ErrorAction Stop | Out-Null

# Wait for the license before install lifetime
[void](Read-Host 'Install the OutSystems license and press Enter to continue the Lifetime setup...')

# Install Lifetime
Publish-OSPlatformLifetime -Verbose -ErrorAction Stop | Out-Null

# -- Apply system tunning and security settings
Set-OSServerPerformanceTunning -Verbose -ErrorAction Stop | Out-Null
Set-OSServerSecuritySettings -Verbose -ErrorAction Stop | Out-Null
