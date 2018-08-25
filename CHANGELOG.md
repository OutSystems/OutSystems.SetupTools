# Outsystems.SetupTools Release History

## 1.8.0.0 - Unreleased

### Added

- New-OSPlatformAllFactorySolution
  - Creates a solution with all apps and modules in the factory. System modules and apps are excluded.

- Export-OSPlatformSolution
  - Exports a solution to a file (OSP file).

- Publish-OSPlatformSolution
  - Publish a solution to the OutSystems environment (OSP/OAP file).

### Changed

- Install-OSPlatformServiceCenter:
  - Change: Removed the write-output. Function by default will not output anything.

- Install-OSServer:
  - Change: Removed the write-output. Function by default will not output anything.

- Publish-OSPlatformLifetime:
  - Change: Removed the write-output. Function by default will not output anything.

- Publish-OSPlatformSystemComponents:
  - Change: Removed the write-output. Function by default will not output anything.

- Set-OSServerPerformanceTunning:
  - Change: Removed the write-output. Function by default will not output anything.

- Get-OSPlatformVersion:
  - Change: Changed parameter -Host to -ServiceCenterHost to standarize with the other functions. -Host is still accepted, so this is not a breaking change.

- Install-OSPlatformLicense:
  - Change: Removed the write-output. Function by default will not output anything.

- Disable-OSServerIPv6:
  - Change: Removed the write-output. Function by default will not output anything.
  - Fix: Fixed the registry value from 0xffffffff to right value 0xff.  (https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users)

- Install-OSServiceStudio:
  - Change: Removed the write-output. Function by default will not output anything.

- Install-OSServerPreReqs:
  - Change: Removed the write-output. Function by default will not output anything.

- Start-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.

- Stop-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.

- Restart-OSServerServices:
  - Change: Removed the write-output. Function by default will not output anything.
  - Change: Improved function.

- Get-OSPlatformApplications:
  - Added: Parameter -Credential (PSCredential type). This should be the preferred way to pass credentials. -ServiceCenterUser and -ServiceCenterPass were not removed for backward compability.
  - Added: User, Pass/Password, Host alias for ServiceCenterUser, ServiceCenterPass, ServiceCenterHost parameters.

- General:
  - Code refactoring to allow better testing and error handling.
  - Added unit testing for all public functions.

## 1.7.0.0

### Added

- Get-OSPlatformApplications.
  - Returns the list of Outsystems applications installed on the environment

- Get-OSPlatformModules.
  - Returns the list of Outsystems modules installed on the environment

### Changed

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
