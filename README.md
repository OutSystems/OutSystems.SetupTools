# OutSystems.SetupTools

[![Build status](https://ci.appveyor.com/api/projects/status/1i4itt105msarmgu/branch/dev?svg=true)](https://ci.appveyor.com/project/pintonunes/OutSystems-setuptools/branch/dev)

OutSystems.SetupTools is a powershell module for installing and manage the OutSystems platform installation.

This module allows you to install and configure the OutSystems platform completely using Powershell.

## Common scenarios

With this module you can:

* Install the platform from a powershell command line.
* Create small scripts to install the platform on your environment and reuse them to reinstall or create other environments.
* Use the module functions in Docker files.
* Create small deployment scripts and use them on Azure ARM templates, AWS Cloudformation, Terraform to automatize the OutSystems deployment on the cloud.
* Use it in Packer to create golden images.

## Quick start

* Install the module from [PowerShell Gallery](https://www.powershellgallery.com/packages/OutSystems.SetupTools):

```powershell
Install-Module -Name OutSystems.SetupTools
Import-Module OutSystems.SetupTools
```

* Test if your system is compliant for installing OutSystems

```powershell
# you should have module imported in the session
Import-Module OutSystems.SetupTools
Test-OSServerHardwareReqs -MajorVersion 10.0
Test-OSServerSoftwareReqs -MajorVersion 10.0
```

* Install the platform pre-requisites:

```powershell
Install-OSServerPreReqs -MajorVersion 10.0
```

* Install the platform server and development environment:

```powershell
Install-OSServer -Version "10.0.823.0" -InstallDir "D:\OutSystems"
Install-OSServiceStudio -Version "10.0.825.0" -InstallDir "D:\OutSystems"
```

* Configure the platform:

```powershell
Invoke-OSConfigurationTool
```

* Install Service Center and the OutSystems systems components:

```powershell
Install-OSPlatformServiceCenter
Publish-OSPlatformSystemComponents
```

* Do the post configuration:

```powershell
Set-OSServerPerformanceTunning
Set-OSServerSecuritySettings
```

## Documentation

Function reference is available at the [docs](docs) folder.
Usage and script examples at the [examples](examples) folder.
