# Outsystems.SetupTools Release History

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
