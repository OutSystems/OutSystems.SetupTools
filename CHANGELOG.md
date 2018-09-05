# Outsystems.SetupTools Release History

## 1.8.0.0 - Unreleased

### What's new

- Support for Outsystems 11 (beta). You can now install and setup Outsystems 11 using this module.
- Lots of code refactoring and improvements. Added unit testing to almost all Cmdlets.
- Redesigned error handling. As best pratices for modules, all errors are now non-terminating.

### Changes

- Install-OSServerPreReqs:
  - Change: Removed the old output messages. Function will now return an object with the result of the installation.
  - Change: We will not throw an exception anymore if a reboot is needed. User should now check the object returned and take care of the reboot.
  - Change: .NET version Change to 4.7.1 to support Outsystems 11.
  - Change: Microsoft repo is now used to download all Microsoft pre-requisites.
  - Fix: Build tools 2015 are now included in the pre-requisites.
  - Added: DotNetCore for Outsystems 11.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Install-OSServer:
  - Change: Removed the old output messages. Function will now return an object with the result of the installation.
  - Fix: Added DefaultParameterSetName to remote install. Function will default to download sources from repo if no parameter is specified.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Install-OSServiceStudio:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fix: Added DefaultParameterSetName to remote install. Function will default to download sources from repo if no parameter is specified.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Renamed Get-OSPlatformServerPrivateKey to Get-OSServerPrivateKey (BREAKING CHANGE):
  - Change: Renamed the function to standarize with the other functions.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSServerInstallDir:
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSServerVersion:
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSServiceStudioInstallDir:
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSServiceStudioVersion:
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- New-OSPlatformPrivateKey:
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Set-OSServerSecuritySettings:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fixed: Wrong registry value while disabling SSL unsafe protocols.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Set-OSServerPerformanceTunning:
  - Change: Removed the write-output. Function by default will not output anything.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Publish-OSPlatformLifetime:
  - Change: Removed the write-output. Function will now return an object with the publish results.
  - Fix: Removed admin rights check. User doesnt need to be admin of the machine. It needs to have permissions on the platform only.
  - Change: Added the -Credential parameter. This will be the default way to pass credentials. The -ServiceCenterUser and the -ServiceCenterPass will be removed in the future (unsecure).
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Publish-OSPlatformSystemComponents:
  - Change: Removed the write-output. Function will now return an object with the publish results.
  - Fix: Removed admin rights check. User doesnt need to be admin of the machine. It needs to have permissions on the platform only.
  - Change: Added the -Credential parameter. This will be the default way to pass credentials. The -ServiceCenterUser and the -ServiceCenterPass will be removed in the future (unsecure).
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Install-OSPlatformServiceCenter:
  - Change: Removed the old output messages. Function will now return an object with the result of the installation.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSPlatformVersion:
  - Change: Change parameter -Host to -ServiceCenterHost to standarize with the other functions. -Host is still accepted, so this is not a breaking change.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.
  - Change: Added pipeline support so you can: "10.0.0.1", "10.0.0.1", "10.0.0.3" | Get-OSPlatformVersion

- Install-OSPlatformLicense:
  - Change: Removed the write-output. Function by default will not output anything.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Disable-OSServerIPv6:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fixed: Change the registry value from 0xffffffff to right value 0xff.  (https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users)

- Start-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Stop-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Restart-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Set-OSInstallLog:
  - Change: Removed the write-output. Function by default will not output anything.

- Set-OSServerWindowsFirewall:
  - Change: Removed the write-output. Function by default will not output anything.
  - Added: Parameter -IncludeRabbitMQ to open the needed ports for RabbitMQ
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Test-OSServerHardwareReqs:
  - Change: Removed the old output messages. Function will now return an object with the result of the tests.
  - BREAKING CHANGE: Added a mandatory parameter -MajorVersion to test version 10 and 11
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Test-OSServerSoftwareReqs:
  - Change: Removed the old output messages. Function will now return an object with the result of the tests.
  - BREAKING CHANGE: Added a mandatory parameter -MajorVersion to test version 10 and 11
  - BREAKING CHANGE: All errors changed to non-terminating errors. Use the "-ErrorAction" Stop parameter or set the variable "$ErrorPreference = Stop" to revert to the old behavior.

- Get-OSPlatformApplications!!!!:
  - Added: Parameter -Credential (PSCredential type). This should be the preferred way to pass credentials. The parameters -ServiceCenterUser and -ServiceCenterPass were not removed for backward compability.
  - Added: User, Pass/Password, Host alias for ServiceCenterUser, ServiceCenterPass, ServiceCenterHost parameters.

- Get-OSPlatformModules!!!!!:
  - Added: Parameter -Credential (PSCredential type). This should be the preferred way to pass credentials. The parameters -ServiceCenterUser and -ServiceCenterPass were not removed for backward compability.
  - Added: User, Pass/Password, Host alias for ServiceCenterUser, ServiceCenterPass, ServiceCenterHost parameters.

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
