# Outsystems.SetupTools Release History

## 1.8.0.0 - Unreleased

### Changes

- Install-OSPlatformServiceCenter:
  - Removed the write-output. Function by default will not output anything.

- Install-OSServer:
  - Removed the write-output. Function by default will not output anything.

- Publish-OSPlatformLifetime:
  - Removed the write-output. Function by default will not output anything.

- Publish-OSPlatformSystemComponents:
  - Removed the write-output. Function by default will not output anything.

- Set-OSServerPerformanceTunning:
  - Removed the write-output. Function by default will not output anything.

- Get-OSPlatformVersion:
  - Changed parameter -Host by -ServiceCenterHost to standarize with the other functions. -Host is still accepted, so this is not a breaking change.

- Install-OSPlatformLicense:
  - Removed the write-output. Function by default will not output anything.

- General:
  - Code refactoring to allow better testing and error handling.

### Fixes

## 1.7.0.0

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

- Added Get-OSPlatformApplications. Returns the list of Outsystems applications installed on the environment
- Added Get-OSPlatformModules. Returns the list of Outsystems modules installed on the environment

### Fixed

- Code improvements and bug fixes
