[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('1[0-1]{1}(\.0)?')]
    [string]$MajorVersion,

    [Parameter()]
    [string]$InstallDir = $("$env:ProgramFiles\OutSystems")
)

#The MajorVersion parameter supports 11.0 or 11. Therefore, we need to remove the '.0' part
$MajorVersion = $MajorVersion.replace(".0","")

# -- Stop on any error
$ErrorActionPreference = 'Stop'

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Install-Module -Name Outsystems.SetupTools -Force | Out-Null
Import-Module -Name Outsystems.SetupTools | Out-Null

# -- Check HW and OS for compability
Test-OSServerHardwareReqs -MajorVersion $MajorVersion -Verbose -ErrorAction Stop | Out-Null
Test-OSServerSoftwareReqs -MajorVersion $MajorVersion -Verbose -ErrorAction Stop | Out-Null

# -- Install PreReqs
$result = Install-OSServerPreReqs -MajorVersion $MajorVersion -Verbose -ErrorAction Stop
if ($result.RebootNeeded)
{
    Write-Warning -Message "OutSystems pre-requisites installed but a reboot is needed. Reboot the machine and then re-run this script!!"
    exit 3010
}

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $(Get-OSRepoAvailableVersions -MajorVersion $MajorVersion -Application 'Lifetime' -Latest) -InstallDir $InstallDir -WithLifetime -Verbose -ErrorAction Stop | Out-Null
Install-OSServiceStudio -Version $(Get-OSRepoAvailableVersions -MajorVersion $MajorVersion -Application 'ServiceStudio' -Latest) -InstallDir $InstallDir -Verbose -ErrorAction Stop | Out-Null

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
