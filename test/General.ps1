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

    DBProvider          = 'SQLExpress'
    DBAuth              = 'SQL'

    DBServer            = '10.0.0.4'
    DBCatalog           = 'OS1'
    DBSAUser            = 'mysa'
    DBSAPass            = 'secret25'

    DBSessionServer     = '10.0.0.4'
    DBSessionCatalog    = 'OS1'
    DBSessionUser       = 'OSSESSION'
    DBSessionPass       = 'iPhone25'

    DBAdminUser         = 'OSADMIN'
    DBAdminPass         = 'iPhone25'
    DBRuntimeUser       = 'OSRUNTIME'
    DBRuntimePass       = 'iPhone25'
    DBLogUser           = 'OSRUNTIME'
    DBLogPass           = 'iPhone25'
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