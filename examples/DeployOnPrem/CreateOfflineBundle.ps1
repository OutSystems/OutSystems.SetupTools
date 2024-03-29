[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('10.0', '11')]
    [string]$MajorVersion
)
Write-Verbose "Starting. Please wait..." -Verbose

# -- Settings and variables
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$OSRepoURLDotNET = 'https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
$OSRepoURLBuildTools = 'https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe'
$OSRepoURLDotNETCore31 = 'https://download.visualstudio.microsoft.com/download/pr/bdc70151-74f7-427c-a368-716d5f1840c5/6186889f6c784bae224eb15fb94c45fe/dotnet-hosting-3.1.14-win.exe'
$OSRepoURLDotNETCore = 'https://download.visualstudio.microsoft.com/download/pr/eebd54bc-c3a2-4580-bb29-b35c1c5ffa92/22ffe5649861167d3d5728d3cb4b10a1/dotnet-hosting-2.1.12-win.exe'
$OSRepoURL = 'https://myfilerepo.blob.core.windows.net/sources'
$OSServerVersion = ""
$OSServiceStudioVersion = ""
$OSLifetimeVersion = ""

# -- Import module from PowerShell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Remove-Module -Name OutSystems.SetupTools -Force -ErrorAction SilentlyContinue
Install-Module -Name Outsystems.SetupTools -Force -WarningAction SilentlyContinue| Out-Null
Import-Module -Name Outsystems.SetupTools | Out-Null

# -- Create the offline bundle folder structure. Remove existing
Write-Verbose "Creating OfflineBundle folder structure" -Verbose
Get-Item -Path "$env:Temp\OSOfflineBundle" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Confirm:$false -Force | Out-Null
New-Item -Path "$env:Temp\OSOfflineBundle" -ItemType Directory -Force -ErrorAction Stop | Out-Null
New-Item -Path "$env:Temp\OSOfflineBundle\Modules" -ItemType Directory -Force -ErrorAction Stop | Out-Null
New-Item -Path "$env:Temp\OSOfflineBundle\PreReqs" -ItemType Directory -Force -ErrorAction Stop | Out-Null
New-Item -Path "$env:Temp\OSOfflineBundle\Sources" -ItemType Directory -Force -ErrorAction Stop | Out-Null

# -- Save the module to the module folder
Write-Verbose "Downloading needed powershell modules" -Verbose
Save-Module -Name OutSystems.SetupTools -Path "$env:Temp\OSOfflineBundle\Modules" -ErrorAction Stop

# -- Download prereqs to the prereqs folder
Write-Verbose "Downloading .NET 4.7.2" -Verbose
(New-Object System.Net.WebClient).DownloadFile($OSRepoURLDotNET, "$env:Temp\OSOfflineBundle\PreReqs\DotNet.exe")
Write-Verbose "Downloading BuildTools 2015" -Verbose
(New-Object System.Net.WebClient).DownloadFile($OSRepoURLBuildTools, "$env:Temp\OSOfflineBundle\PreReqs\BuildTools_Full.exe")
Write-Verbose "Downloading .NET Core 2.1 Windows Server Hosting bundle" -Verbose
(New-Object System.Net.WebClient).DownloadFile($OSRepoURLDotNETCore, "$env:Temp\OSOfflineBundle\PreReqs\DotNetCore_WindowsHosting.exe")
Write-Verbose "Downloading .NET Core 3.1 Windows Server Hosting bundle" -Verbose
(New-Object System.Net.WebClient).DownloadFile($OSRepoURLDotNETCore31, "$env:Temp\OSOfflineBundle\PreReqs\DotNetCore_WindowsHosting_31.exe")

# -- Download outsystems
$OSServerVersion = Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion $MajorVersion -Latest
$OSServiceStudioVersion = Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion $MajorVersion -Latest
$OSLifetimeVersion = Get-OSRepoAvailableVersions -Application 'Lifetime' -MajorVersion '11' -Latest

Write-Verbose "Downloading OutSystems Platform Server $OSServerVersion" -Verbose
(New-Object System.Net.WebClient).DownloadFile("$OSRepoURL\PlatformServer-$OSServerVersion.exe", "$env:Temp\OSOfflineBundle\Sources\PlatformServer-$OSServerVersion.exe")
Write-Verbose "Downloading OutSystems Developement Environment $OSServiceStudioVersion" -Verbose
(New-Object System.Net.WebClient).DownloadFile("$OSRepoURL\DevelopmentEnvironment-$OSServiceStudioVersion.exe", "$env:Temp\OSOfflineBundle\Sources\DevelopmentEnvironment-$OSServiceStudioVersion.exe")
Write-Verbose "Downloading OutSystems Lifetime $OSLifetimeVersion" -Verbose
(New-Object System.Net.WebClient).DownloadFile("$OSRepoURL\LifeTimeWithPlatformServer-$OSLifetimeVersion.exe", "$env:Temp\OSOfflineBundle\Sources\LifeTimeWithPlatformServer-$OSLifetimeVersion.exe")

# -- Download scripts
$OSGitHubDownloadURL = "https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem"
Write-Verbose "Downloading installation scripts from github" -Verbose
(New-Object System.Net.WebClient).DownloadFile("$OSGitHubDownloadURL\OnPrem-Offline-DC.ps1", "$env:Temp\OSOfflineBundle\OnPrem-Offline-DC.ps1")
(New-Object System.Net.WebClient).DownloadFile("$OSGitHubDownloadURL\OnPrem-Offline-FE.ps1", "$env:Temp\OSOfflineBundle\OnPrem-Offline-FE.ps1")
(New-Object System.Net.WebClient).DownloadFile("$OSGitHubDownloadURL\OnPrem-Offline-LT.ps1", "$env:Temp\OSOfflineBundle\OnPrem-Offline-LT.ps1")

# -- Create configuration object for the scripts, serialize and export to file
$OfflineConfiguration = [PSCustomObject]@{
    ServerVersion = $OSServerVersion
    ServiceStudioVersion = $OSServiceStudioVersion
    LifetimeVersion = $OSLifetimeVersion
}
$OfflineConfiguration | Export-Clixml -Path "$env:Temp\OSOfflineBundle\Configuration.xml"

# -- Zip and delete folder
Write-Verbose "Creating zip file bundle ..." -Verbose
Compress-Archive -Path "$env:Temp\OSOfflineBundle\*" -CompressionLevel Fastest -DestinationPath "$PSScriptRoot\OSOfflineBundle.zip" -Force -ErrorAction Stop

# -- The end
Write-Verbose "Done...!! Package is ready!" -Verbose
