[CmdletBinding()]
param(
    [Parameter()]
    [string]$InstallDir = $("$env:ProgramFiles\OutSystems")
)

# -- Stop on any error
$ErrorActionPreference = 'Stop'

# -- Import configuration file
$OfflineConfiguration = Import-Clixml "$PSScriptRoot\Configuration.xml"
$majorVersion = "$($([version]$OfflineConfiguration.ServerVersion).Major).$($([version]$OfflineConfiguration.ServerVersion).Minor)"

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
    Write-Warning -Message "OutSystems pre-requisites installed but a reboot is need. Restart the script after rebooting!!"
    exit 3010
}

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $OfflineConfiguration.ServerVersion -InstallDir $InstallDir -SourcePath "$PSScriptRoot\Sources" -SkipRabbitMQ -Verbose -ErrorAction Stop | Out-Null
Install-OSServiceStudio -Version $OfflineConfiguration.ServiceStudioVersion -InstallDir $InstallDir -SourcePath "$PSScriptRoot\Sources" -Verbose -ErrorAction Stop | Out-Null

# Start configuration tool
Write-Output "Copy the private.key and server.hsconf from the Deployment Controller and launch the configuration tool manually... "
[void](Read-Host 'Configure the platform and press Enter to continue the OutSystems setup...')

# -- Apply system tunning and security settings
Set-OSServerPerformanceTunning -Verbose -ErrorAction Stop | Out-Null
Set-OSServerSecuritySettings -Verbose -ErrorAction Stop | Out-Null
