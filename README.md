# Outsystems.SetupTools

Outsystems.SetupTools is a powershell module for installing and manage the Outsystems platform installation.

This module allows you to install and configure the Outsystems platform completely using Powershell.

## Common scenarios

With this module you can:
* Install the platform from a powershell command line
* Create small scripts to install the platform on your environment and reuse them to reinstall or create other environments
* Use the module functions in Docker files
* Create small deployment scripts and use them on Azure ARM templates, AWS Cloudformation, Terraform to automatize the Outsystems deployment on the cloud

## Quick start

* Install platyPS module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Outsystems.SetupTools):

```powershell
Install-Module -Name Outsystems.SetupTools
Import-Module Outsystems.SetupTools
```

* Test if your system is compliant for installing Outsystems

```powershell
# you should have module imported in the session
Import-Module Outsystems.SetupTools
Test-OSPlatformHardwareReqs
Test-OSPlatformSoftwareReqs
```

* Install the platform pre-requisites:

```powershell
Install-OSPlatformPreReqs -MajorVersion 10.0
```

* Install the platform server and development environment:

```powershell
Install-OSPlatformServer -Version "10.0.823.0" -InstallDir "D:\Outsystems"
Install-OSDevEnvironment -Version "10.0.825.0" -InstallDir "D:\Outsystems"
```

* Configure the platform:

```powershell
Invoke-OSConfigurationTool
```

* Install Service Center and the Outsystems systems components:

```powershell
Install-OSPlatformServiceCenter
Install-OSPlatformSystemComponents
```

* Do the post configuration:

```powershell
Set-OSPlatformPerformanceTunning
Set-OSPlatformSecuritySettings
```