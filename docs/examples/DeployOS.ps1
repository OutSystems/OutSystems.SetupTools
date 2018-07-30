# ------------- Outsystems environment configuration  ------------------

# The server role.
# This can be "FE" for FrontEnd or "LT" for lifetime. Defaults to controller.
$OSRole=""
#$OSRole="FE"
#$OSRole="LT"

# The version of the platform that will be installed.
$OSPlatformVersion='10.0.823.0'
$OSDevEnvironmentVersion='10.0.825.0'

# Where the platform will be installed.
$OSInstallDir="$Env:ProgramFiles\OutSystems"
#$OSInstallDir="D:\OutSystems"

# IIS Temp folders
$OSIISNetCompilationDir=""
$OSIISHttpCompressionDir=""

# Where the license is located. If you dont specify a license path here, a trial license will be installed.
$OSLicensePath=""
#$OSLicensePath="$PSScriptRoot"
#$OSLicensePath="D:\sources"

# Log location
$OSLogPath="$Env:Windir\Temp\OutsystemsInstall"

# Set to true if you want to see verbose output in the console
$Verbose=$true

# Configuration tool parameters
$ConfigToolArgs = @{

    # If this is a frontend or you want to connect to an existing database environment specify the environment private key here.
    # If this is a Farm deployment, you should generate a new private key using the cmdlet New-OSPlatformPrivateKey.
    # If empty, a random one will be generated.
    PrivateKey          = ""

    # If this is a frontend specify the controller IP address here. Otherwise leave this blank!!!
    Controller          = ""

    DBProvider          = "SQL"                 # Possible values: SQL, SQLExpress, AzureSQL
    DBAuth              = "SQL"                 # Possible values: SQL or Windows

    DBServer            = "<SQL server>"        # SQL server IP or hostname
    DBCatalog           = "outsystems"          # Platform catalog
    DBSAUser            = "sa"                  # User with dba permission on the database. If windows auth, this should be <DOMAIN\USER>
    DBSAPass            = "<sa password>"

    DBSessionServer     = "<SQL server>"        # SQL server IP or hostname for the session catalog
    DBSessionCatalog    = "osSession"           # Session catalog
    DBSessionUser       = "OSSTATE"             # Session DB User
    DBSessionPass       = "<OSSTATE pass>"      # Session DB Pass

    DBAdminUser         = "OSADMIN"             # Admin DB User
    DBAdminPass         = "<OSADMIN pass>"      # Admin DB Pass
    DBRuntimeUser       = "OSRUNTIME"           # Runtime DB User
    DBRuntimePass       = "<OSRUNTIME pass>"    # Runtime DB Pass
    DBLogUser           = "OSLOG"               # Log DB User
    DBLogPass           = "<OSLOG pass>"        # Log DB User
}

# ------------- Outsystems environment configuration ------------------
# ----------- DO NOT CHANGE ANYTHING BELLOW THIS LINE -----------------
# -- Stop on any error
$ErrorActionPreference = "Stop"

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
Install-Module Outsystems.SetupTools -Version "1.6.30.0" -Force
Import-Module Outsystems.SetupTools

# -- Start logging
Set-OSInstallLog -Path $OSLogPath -File "InstallLog-$(get-date -Format 'yyyyMMddHHmmss').log" -Verbose:$Verbose

# -- Check HW and OS for compability
Test-OSServerHardwareReqs -Verbose:$Verbose
Test-OSServerSoftwareReqs -Verbose:$Verbose

# -- Install PreReqs
Install-OSServerPreReqs -MajorVersion "$(([System.Version]$OSPlatformVersion).Major).$(([System.Version]$OSPlatformVersion).Minor)" -Verbose:$Verbose

# -- Download and install OS Server and Dev environment from repo
Install-OSPlatformServer -Version $OSPlatformVersion -InstallDir $OSInstallDir -Verbose:$Verbose
Install-OSDevEnvironment -Version $OSDevEnvironmentVersion -InstallDir $OSInstallDir -Verbose:$Verbose

# -- Configure windows firewall
Set-OSPlatformWindowsFirewall -Verbose:$Verbose

# -- Disable IPv6
Disable-OSIPv6 -Verbose:$Verbose

# -- If this is a frontend, wait for the controller to become available
If ($OSRole -eq "FE"){
    While ( -not $(Get-OSPlatformVersion -Host $ConfigToolArgs.Controller -ErrorAction SilentlyContinue) ) {
        Write-Output "Waiting for the controller $($ConfigToolArgs.Controller)"
        Start-Sleep -s 15
    }
    Write-Output "Controller $($ConfigToolArgs.Controller) available. Wait more 15 seconds for full initialization"
    Start-Sleep -s 15
}

# -- Run config tool
Invoke-OSConfigurationTool @ConfigToolArgs -Verbose:$Verbose

# -- If this is a frontend, disable the controller service and wait for the service center to be published by the controller before running the system tunning
If ($OSRole -eq "FE"){

    Get-Service -Name "OutSystems Deployment Controller Service" | Stop-Service -WarningAction SilentlyContinue
    Set-Service -Name "OutSystems Deployment Controller Service" -StartupType "Disabled"

    While ( -not $(Get-OSPlatformVersion -ErrorAction SilentlyContinue) ) {
        Write-Output "Waiting for service center to be published"
        Start-Sleep -s 15
    }
    Write-Output "Service Center available. Wait more 15 seconds for full initialization"
    Start-Sleep -s 15
} Else {
    # -- If not a frontend install Service Center, SysComponents and license
    Install-OSPlatformServiceCenter -Verbose:$Verbose
    Publish-OSPlatformSystemComponents -Verbose:$Verbose
    Install-OSPlatformLicense -Path $OSLicensePath -Verbose:$Verbose
}

# -- Install Lifetime if role is LT
If ($OSRole -eq "LT"){
    Publish-OSPlatformLifetime -Verbose:$Verbose
}

# -- System tunning
Set-OSPlatformPerformanceTunning -Verbose:$Verbose -IISNetCompilationPath $OSIISNetCompilationDir -IISHttpCompressionPath $OSIISHttpCompressionDir

# -- Security settings
Set-OSPlatformSecuritySettings -Verbose:$Verbose
