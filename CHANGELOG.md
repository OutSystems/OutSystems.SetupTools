# Outsystems.SetupTools Release History

## 1.7.0.0 (Unreleased)
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

  - Added Get-OSPlatformApplications. Returns the list of Outsystems applications installed on the environment
  - Added Get-OSPlatformModules. Returns the list of Outsystems modules installed on the environment
  - Code improvements and bug fixes
