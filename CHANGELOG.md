# OutSystems.SetupTools Release History

## 4.0.0.0

- Remove support for O10
- Install command lines for development environments (Service Studio and Integration Studio) now only accept O11 major versions
- Install command lines for Platform Server and LifeTime now have set minimum version for 11.23.0. If the minor version is not specified it will now target minor 23 instead of the latest
- FIPS will only be disabled automatically for versions below 11.38.0

## 3.19.0.0

- Remove RabbitMQ/Erlang automatic installation by default, making SkipRabbitMQ switch obsolete. In order to install and configure RabbitMQ/Erlang, the command Set-OSServerConfig with parameter -ConfigureCacheInvalidationService should be used instead. (#146)
- Fix issues with Get-OSRepoAvailableVersions (#150)

## 3.18.2.0

- Add ServiceCenter validation and setting ACLs for IISCompression and NETCompilation folders (#142)
- Add missing InstallMSBuildTools parameter to comment-based help (#141)
- Fix issues of Publish-OSPlatformSolution with two step publishing (#140)
- Replace use of AzureRM with Azure Blob Storage REST API to remove dependency of AzureRM (#139)
- Fix issues with odd filenames in repo and add Service Studio and Integration Studio as separate installers (#138)
- Fix minimum Platform Server version that requires .NET 8.0 Windows Hosting Bundle (#136)
- Fix Get-OSPlatformDeploymentZone not getting output from ExecuteCommand function (#137)

## 3.18.1.0

- Ensure MS Build Tools is installed for first installs of Platform Server versions < 11.35.0
- Fix Set-OSServerPerformanceTunning2 not moving PerformanceMonitor to LifeTimeAppPool (#132)

## 3.18.0.0

- Make MS Build Tools installation optional for Platform Server versions 11 or greater. Platform Server version 10 still installs MS Build Tools.
- Fix for "Set-OSServerConfig fails if value of setting includes an ampersand (&) character" #127

## 3.17.1.0
- Exclude Server.API and Server.Identity from being moved to another app pool (#122)

- Exclude Server.API and Server.Identity IIS apps from being moved to the OutSystemsApplications app pool by Set-OSServerPerformanceTunning and Set-OSServerPerformanceTunning2

## 3.17.0.0

- Upgrade the hosting bundle to .NET 8.0

## 3.16.3.0

- Added CentralizedPlatformLogs extension to installer arguments for versions above 11.18.1

## 3.16.2.1

- Implement flag to uninstall previous .NET Core packages when installing the hosting bundle
- Implement flag to skip the installation of the .NET Core Runtime and the ASP.NET Runtime when installing the hosting bundle

## 3.16.1.0

- Adapt build script for new Service Studio installer
- Added build script for new Integration Studio installation

## 3.16.0.0

- Upgrade the hosting bundle to .NET 6.0

## 3.15.0.0

- Fix lifetime installer checks

## 3.14.3.0

- Adjust maxRequest constants to be used during tuning

## 3.14.2.0

- Updated Get-OSServerPreReqs. Fix for .NET hosting bundle 3.1 installation

## 3.14.1.0

- Updated Install-OSServerPreReqs. Fix OutSystems version for .NET hosting bundle 3.1 installation
## 3.14.0.0

- Updated Install-OSServerPreReqs. Install .NET Core hosting bundle version 3.1.14 only if we are above OutSystems version 11.12.2.0. Added parameters so the full OutSystems version can be specified

## 3.13.1.0

- Fixed Get-OSRepoAvailableVersions. Was getting versions from an old storage account

## 3.13.0.0

- Updated Install-OSServerPreReqs. Now installs .NET Core hosting bundle version 3.1.14 and 2.1.12. The new .NET Core version is a pre-req of newer OutSystems 11 versions. To maintain compability we decided to install both versions
- Masked sensitive information from log files

## 3.12.0.0

- Updated .NET Core to 3.1.14

## 3.11.1.0

- Fix Set-OSServerConfig and Get-OSServerConfig bug introduced in 3.11.0.0 version

## 3.11.0.0

- Change Set-OSServerConfig and Get-OSServerConfig to allow properties with numbers

## 3.10.1.0

- Fixed Publish-OSPlatformLifetime when updating lifetime with newer lifetime versions
## 3.10.0.0

- Support for OutSystems major versions

## 3.9.0.0

- Install-OSServer: Fixed a bug when trying to update lifetime installer
- Get-OSServerInfo: Added Lifetime version output

## 3.8.0.0

- Updated the OutSystems repo for downloading sources

## 3.7.1.0

- Publish-OSPlatformLifetime: Allowed to run after a Platform Server upgrade

## 3.7.0.0

- Set-OSServerConfig: Added SectionAttribute and SectionAttributeValue parameters

## 3.6.2.0

- Set-OSServerConfig: Fixed a bug introduced in the 3.6.0.0 version

## 3.6.1.0

- Set-OSServerConfig: Fixed a bug introduced in the 3.6.0.0 version

## 3.6.0.0

- Get-OSServerPreReqs: Fixed bug that caused script to output wrong error message
- Set-OSServerConfig: Added -IntegratedAuthPassword for upgrading environments using windows authentication
- Set-OSServerConfig: Fixed -UpgradeEnvironment switch

## 3.5.0.0

- Get-OSServerPreReqs: Now check if IIS can find ASP.NET modules

## 3.4.0.0

- ExecuteCommand: Enabled real time logging for all executed processes. This impacts the execution of PlatformInstaller, ConfigTool, Scinstall

## 3.3.3.0

- PlatformSetup: Now all expected files are using canonical names and code improvement

## 3.3.2.0

- Get-OSServerPreReqs: Now Windows event logs configurations are optional and don't block installer

## 3.3.1.0

- Install-OSServer: Fixed -AdditionalParameters switch

## 3.3.0.0

- Install-OSServer: Added -Force and -AdditionalParameters switch

## 3.2.0.0

- Added another database option to New-OSServerConfig

## 3.1.0.0

- Added support for OutSystems 11.X.X.X

## 3.1.0-apha

- Added a new parameter -UpgradeEnvironment to the Set-OSServerConfig
- Fixed date/time format in logs.

### Changes

- Fixed Install-OSPlatformSystemComponents. Now supports the old and the new versioning

## 3.0.1-apha

### Changes

- Fixed Install-OSPlatformSystemComponents. Now supports the old and the new versioning

## 3.0.0-apha

### Changes

- First release to support the platform server new versioning system

## 2.11.2.0

### Changes

- Added "_" as valid char in the Set-OSServerConfig, Setting parameter

## 2.11.1.0

### Changes

- Raise .NET Core 2.1 Hosting Bundle requirement to 2.1.12 due to security patch

## 2.11.0.0

### Changes

- Updated installed DotNetCore to version 2.1.11. New pre-requirement of the platform
- First code refactoring to be able to merge the OutSystems installer version of the module

## 2.10.0.0

### Changes

- Added parameter -InstallServiceCenter to Set-OSServerConfig to enable the installation of service center during the configuration tool execution

## 2.9.0.0

### Changes

- Changed Set-OSServerConfig. Added -SkipSessionRebuild parameter

## 2.8.1.0

### Changes

- Fixed a bug introduced on the upgraded of the .NET requirement to 4.7.2

## 2.8.0.0

### Changes

- Fixed Get-OSRepoAvailableVersions. In some cases was not returning the latest version when -Latest was specified.
- Changed Install-OSServerPreReqs. Upgraded .NET requirement to 4.7.2

## 2.7.0.0

### Changes

- Added new function Publish-OSPlatformSolutionPack. Publish a solution using OSPTool
- Changed logging. Now will output also to the Information stream if cmdLet is called using -InformationAction:Continue

## 2.6.0.0

### Changes

- New function Write-OSInstallLog. To write messages on the install log and the verbose stream
- Install-OSServer. Added -FullPathInstallDir switch
- Changed FullPathInstallDir parameter on Install-OSServer and Install-OSServiceStudio to dynamic. Only available when InstallDir parameter is specified

## 2.5.3.0

### Changes

- Install-OSServiceStudio. Added -FullPathInstallDir switch

## 2.5.1.0 and 2.5.2.0

### Changes

- Fixed internal function regarding service studio installation. Was throwing an error when service studio was not installed

## 2.5.0.0

### Changes

- Added Get-OSServerInfo. New function that returns the server installdir, version, machine name, serial and privateKey. Deprecates Get-OSServerInstallDir Get-OSServerVersion, Get-OSServerPrivateKey
- Added Get-OSServiceStudioInfo: New function that returns the service studio installdir and version. Deprecates Get-OSServiceStudioInstallDir Get-OSServiceStudioVersion
- Removed Invoke-OSConfigurationTool. Deprecated for a long time
- Added Get-OSPlatformDeploymentZone. New function that returns the environment deployment zones
- Added Get-OSPlatformDeploymentZone. New function that sets the environment deployment zone address

## 2.4.3.0

### Changes

- Set-OSServerPerformanceTunning: Fixed an issue with newer powershell versions.

## 2.4.2.0

### Changes

- Set-OSServerConfig: Fixed an issue when trying to set a parameter on an empty XML node.

## 2.4.1.0

### Changes

- Install-OSPlatformLicense: Fixed bug when a local path is specified.

## 2.4.0.0

### Changes

- Install-OSServerPreReqs: Added parameter -SourcePath. The cmdLet can now use a local folder containning the pre-reqs binaries.

## 2.3.5.0

### Changes

- Implemented workaround to avoid the configuration tool to throw the error: The process cannot access the file 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\machine.config' because it is being used by another process.

## 2.3.1.0

### Changes

- Fixed a bug Get-OSRepoAvailableVersions when Lifetime is specified as application with the -Latest paramater.
- Updated Get-OSPlatformApplications help.

## 2.3.0.0

### What's new

- Added support for Lifetime in Install-OSServer and Get-OSRepoAvailableVersions

### Changes

- Fixed Install-OSServer. Now throws if an empty/null -InstallDir, -SourcePath and -Version parameters is specified.
- Fixed Install-OSServiceStudio. Now throws if an empty/null -InstallDir, -SourcePath and -Version parameters is specified.

## 2.2.0.0

### What's new

- New functions Get-OSRepoAvailableVersions, New-OSServerConfig, Get-OSServerConfig, Set-OSServerConfig

### Changes

- Install-OSServer:
  - Added: This cmdLet will now install RabbitMQ and Erlang if version specified is OutSystems 11
  - Added: Parameter -SkipRabbitMQ that will skip the RabbitMQ installation if specified

- Install-OSRabbitMQ:
  - (BREAKING CHANGE): This cmdLet was removed. The installation is performed by the Install-OSServer and the configuration is done by the configuration tool

- Invoke-OSConfigurationTool
  - This cmdlet is now deprecated and will be removed in the next version. Use the New-OSServerConfig and the Set-OSServerConfig for configuring the platform

## 2.1.0.0

### What's new

- New function Publish-OSPlatformSolution and Publish-OSPlatformModules
- New function Set-OSServer

### Changes

- Install-OSRabbitMQ:
  - Added: Restricted RabbitMQ management to localhost.
    - Changed: Removed dependency from the Platform server.
    - Added: InstallDir parameter
    - Changed: Changed RabbitMQ configuration gate. Added a configuration flag to know if needs to be performed or not based on the last install

- Publish-OSPlatformSolution: New function to publish an OSP/OAP

- Publish-OSPlatformModules: New function publish modules into an environment

- Set-OSServer: New function to replace the Invoke-OSConfigurationTool

- Get-OSPlatformApplications:
  - (BREAKING CHANGE): Removed the -ServiceCenterUser and -ServiceCenterPass. Now the cmdlet only accepts -Credential for authentication
  - Major rework

- Get-OSPlatformModules:
  - (BREAKING CHANGE): Removed the -ServiceCenterUser and -ServiceCenterPass. Now the cmdlet only accepts -Credential for authentication
  - Major rework

## 2.0.1.0

### Changes

- Set-OSServerWindowsFirewall:
  - Changed: IncludeRabbitMQ parameter is now a switch and not a boolean

- Set-OSServerPerformanceTunning:
  - Added: IIS rapid fail protection. Sets the value to False
  - Fixed: IIS Application Pool private memory allocation was set in Gigabytes and not in Kilobytes

## 2.0.0.0

### What's new

- Support for Outsystems 11. You can now install and setup Outsystems 11 using this module.
- Major redesign of the module code. Lots of refactoring, improvements on all CmdLets and lots of bug fixes.
- Added unit testing to almost all CmdLets.
- (BREAKING CHANGE) Redesigned error handling. As best pratices for modules, all errors are now non-terminating. You should use the -ErrorAction parameter or the $global:ErrorPreference variable. To stop on any error (previous behavior) add $global:ErrorActionPreference = 'Stop' on the top of the script.
- Removed output sentences from all CmdLets. CmdLets will not output anything or will output an object result.

### Changes

- Install-OSRabbitMQ: New function to install and configure RabbitMQ

- Install-OSServerPreReqs:
  - Change: Function will now return an object with the result of the installation.
  - Change: We will not throw an exception anymore if a reboot is needed. User should now check the object returned and take care of the reboot.
  - Change: .NET version Change to 4.7.1 to support Outsystems 11.
  - Change: Microsoft repo is now used to download all Microsoft pre-requisites.
  - Fix: Build tools 2015 are now included in the pre-requisites.
  - Add: DotNetCore for Outsystems 11.

- Install-OSServer:
  - Change: Removed the old output messages. Function will now return an object with the result of the installation.
  - Fix: Added DefaultParameterSetName to remote install. Function will default to download sources from repo if no parameter is specified.

- Install-OSServiceStudio:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fix: Added DefaultParameterSetName to remote install. Function will default to download sources from repo if no parameter is specified.

- Renamed Get-OSPlatformServerPrivateKey to Get-OSServerPrivateKey (BREAKING CHANGE):
  - Change: Renamed the function to standarize with the other functions.

- Set-OSServerSecuritySettings:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fixed: Wrong registry value while disabling SSL unsafe protocols.

- Set-OSServerPerformanceTunning:
  - Change: Removed the write-output. Function by default will not output anything.

- Publish-OSPlatformLifetime:
  - Change: Removed the write-output. Function will now return an object with the publish results.
  - Fix: Removed admin rights check. User doesnt need to be admin of the machine. It needs to have permissions on the platform only.
  - Change: Added the -Credential parameter. This will be the default way to pass credentials. The -ServiceCenterUser and the -ServiceCenterPass will be removed in the future (unsecure).

- Publish-OSPlatformSystemComponents:
  - Change: Removed the write-output. Function will now return an object with the publish results.
  - Fix: Removed admin rights check. User doesnt need to be admin of the machine. It needs to have permissions on the platform only.
  - Change: Added the -Credential parameter. This will be the default way to pass credentials. The -ServiceCenterUser and the -ServiceCenterPass will be removed in the future (unsecure).

- Install-OSPlatformServiceCenter:
  - Change: Removed the old output messages. Function will now return an object with the result of the installation.

- Get-OSPlatformVersion:
  - Change: Change parameter -Host to -ServiceCenterHost to standarize with the other functions. -Host is still accepted, so this is not a breaking change.
  - Change: Added pipeline support so you can: "10.0.0.1", "10.0.0.1", "10.0.0.3" | Get-OSPlatformVersion

- Install-OSPlatformLicense:
  - Change: Removed the write-output. Function by default will not output anything.

- Disable-OSServerIPv6:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fixed: Change the registry value from 0xffffffff to right value 0xff.  (https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users)

- Start-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.

- Stop-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.

- Restart-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.

- Set-OSInstallLog:
  - Change: Removed the write-output. Function by default will not output anything.

- Set-OSServerWindowsFirewall:
  - Change: Removed the write-output. Function by default will not output anything.
  - Add: Parameter -IncludeRabbitMQ to open the needed ports for RabbitMQ

- Test-OSServerHardwareReqs:
  - Change: Removed the old output messages. Function will now return an object with the result of the tests.
  - BREAKING CHANGE: Added a mandatory parameter -MajorVersion to test version 10 and 11

- Test-OSServerSoftwareReqs:
  - Change: Removed the old output messages. Function will now return an object with the result of the tests.
  - BREAKING CHANGE: Added a mandatory parameter -MajorVersion to test version 10 and 11

- Invoke-OSConfigurationTool:
  - Change: Removed the write-output. Function by default will not output anything.
  - Add: Support for Outsystems 11.
  - Changed: The only mandatory parameters are now the DB SA account and the DB accounts passwords. Everything else will use the configuration tool defaults if not specified.

## 1.7.0.0

### What's new

- Two new functions: Get-OSPlatformApplications and Get-OSPlatformModules.

- Get-OSPlatformApplications.
  - Returns the list of Outsystems applications installed on the environment

- Get-OSPlatformModules.
  - Returns the list of Outsystems modules installed on the environment

### Changes

- New name convention for functions. Every function related with the server itself will have the prefix XXX-OSServer. Everything related with the platform or the environment will have the prefix XXX-OSPlatform.
  - Renamed Get-OSPlatformServerVersion to Get-OSServerVersion
  - Renamed Get-OSPlatformServerInstallDir to Get-OSServerInstallDir
  - Renamed Install-OSPlatformServer to Install-OSServer
  - Renamed Install-OSDevEnvironment to Install-OSServiceStudio
  - Renamed Disable-OSIPv6 to Disable-OSServerIPv6
  - Renamed Set-OSPlatformPerformanceTunning to Set-OSServerPerformanceTunning
  - Renamed Set-OSPlatformSecuritySettings to Set-OSServerSecuritySettings
  - Renamed Set-OSPlatformWindowsFirewall to Set-OSServerWindowsFirewall
  - Renamed Test-OSPlatformHardwareReqs to Test-OSServerHardwareReqs
  - Renamed Test-OSPlatformSoftwareReqs to Test-OSServerSoftwareReqs
  - Renamed Start-OSServices to Start-OSServerServices
  - Renamed Stop-OSServices to Stop-OSServerServices
  - Renamed Restart-OSServices to Restart-OSServerServices
  - Renamed Get-OSDevEnvironmentInstallDir to Get-OSServiceStudioInstallDir
  - Renamed Get-OSDevEnvironmentVersion to Get-OSServiceStudioVersion
  - Renamed Install-OSPlatformSystemComponents to Publish-OSPlatformSystemComponents
  - Renamed Install-OSPlatformLifetime to Publish-OSPlatformLifetime
  - Renamed Install-OSPlatformPreReqs to Install-OSServerPreReqs

- Code improvements and bug fixes
