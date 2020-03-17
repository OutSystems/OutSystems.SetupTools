[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('10.0', '11')]
    [string]$MajorVersion,

    [Parameter()]
    [string]$InstallDir = $("$env:ProgramFiles\OutSystems")
)

# -- Stop on any error
$ErrorActionPreference = 'Stop'

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Install-Module -Name Outsystems.SetupTools -Force | Out-Null

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
Install-OSServer -Version $(Get-OSRepoAvailableVersions -MajorVersion $MajorVersion -Application 'PlatformServer' -Latest) -InstallDir $InstallDir -SkipRabbitMQ -Verbose -ErrorAction Stop | Out-Null
Install-OSServiceStudio -Version $(Get-OSRepoAvailableVersions -MajorVersion $MajorVersion -Application 'ServiceStudio' -Latest) -InstallDir $InstallDir -Verbose -ErrorAction Stop | Out-Null

# Start configuration tool
Write-Output "Copy the private.key and server.hsconf from the Deployment Controller and launch the configuration tool manually... "
[void](Read-Host 'Configure the platform and press Enter to continue the OutSystems setup...')

# -- Apply system tunning and security settings
Set-OSServerPerformanceTunning -Verbose -ErrorAction Stop | Out-Null
Set-OSServerSecuritySettings -Verbose -ErrorAction Stop | Out-Null
