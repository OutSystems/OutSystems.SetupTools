# OutSystems.SetupTools

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/outsystems.setuptools.svg)
![AppVeyor](https://img.shields.io/appveyor/ci/pintonunes/OutSystems-setuptools.svg)![AppVeyor tests](https://img.shields.io/appveyor/tests/pintonunes/OutSystems-setuptools.svg)

OutSystems.SetupTools is a powershell module for installing and manage the OutSystems platform installation.

This module allows you to install and configure the OutSystems platform completely using Powershell.

## Branches

### master

This is the branch containing the latest release - no contributions should be made directly to this branch.

### dev



This is the development branch to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

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
```

* Test if your system is compliant for installing OutSystems

```powershell
Test-OSServerHardwareReqs -MajorVersion 11.0
Test-OSServerSoftwareReqs -MajorVersion 11.0
```

* Install the platform pre-requisites:

```powershell
Install-OSServerPreReqs -MajorVersion 11.0
```

* Install the platform server and development environment:

```powershell
Install-OSServer -Version "11.0.108.0" -InstallDir "D:\OutSystems"
Install-OSServiceStudio -Version "11.0.108.0" -InstallDir "D:\OutSystems"
```

* Configure the platform :

```powershell
New-OSServerConfig -DatabaseProvider 'SQL'
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'RuntimePassword' -Value 'mypassword'
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'SessionPassword' -Value 'mypassword'
...
...
Set-OSServerConfig -Apply -ConfigureCacheInvalidationService
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

## Disclaimer

Hopefully this is obvious, but:

> This is an open source project (under the [Apache v2 license]), and all contributors are volunteers. All commands are executed at your own risk.
This module is not supported by OutSystems.

