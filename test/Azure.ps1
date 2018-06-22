# -- Import module from Powershell Gallery
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
#Install-Module Outsystems.SetupTools -Force
#Import-Module Outsystems.SetupTools

# -- Import module local
Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
Import-Module .\..\..\src\Outsystems.SetupTools

$ConfigToolArgs = @{
    InstallType         = 'Standalone'

    DBProvider          = 'AzureSQL'
    DBAuth              = 'SQL'

    DBServer            = 'myoutsystems.database.windows.net'
    DBCatalog           = 'os1'
    DBSAUser            = 'pjn'
    DBSAPass            = 'Secret25'

    DBSessionServer     = 'myoutsystems.database.windows.net'
    DBSessionCatalog    = 'os1'
    DBSessionUser       = 'pjn'
    DBSessionPass       = 'Secret25'

    DBAdminUser         = 'pjn'
    DBAdminPass         = 'Secret25'
    DBRuntimeUser       = 'pjn'
    DBRuntimePass       = 'Secret25'
    DBLogUser           = 'pjn'
    DBLogPass           = 'Secret25'
  }

# -- Check HW and OS for compability
Test-OSPlatformHardwareReqs -Verbose
Test-OSPlatformSoftwareReqs -Verbose

# -- Install PreReqs
Install-OSPlatformServerPreReqs -Verbose

# -- Download and install OS Server and Dev environment from repo
Install-OSPlatformServer -Version 10.0.816.0 -Verbose
Install-OSDevEnvironment -Version 10.0.822.0 -Verbose

# -- Download and install OS Server and Dev environment from local source
#Install-OSPlatformServer -SourcePath "$PSScriptRoot\Sources" -Version 10.0.816.0 -Verbose
#Install-OSDevEnvironment -SourcePath "$PSScriptRoot\Sources" -Version 10.0.822.0 -Verbose

# -- Configure environment
Invoke-OSConfigurationTool -Verbose @ConfigToolArgs

# -- Install Service Center and SysComponents
Install-OSPlatformServiceCenter -Verbose
Install-OSPlatformSysComponents -Verbose

# -- Install license
Install-OSPlatformLicense -Path "$PSScriptRoot\Sources\license.lic" -Verbose

# -- Install Lifetime
Install-OSPlatformLifetime -Verbose

# -- System tunning
#Set-OSPlatformPerformanceTunning -Verbose

# -- Security settings
#Set-OSPlatformSecuritySettings -Verbose