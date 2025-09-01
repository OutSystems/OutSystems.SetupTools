# Requirements

Validate if you have `Pester` version 4.10.1 at least to run the tests

```
Get-Module Pester -ListAvailable
```

By default `Powershell` comes with 3.4.0 but we need at least 4.10.1 for some of our tests otherwise they will fail.


```
Install-Module Pester -RequiredVersion 4.10.1
```

------

# How to run tests

To execute tests, we need to use `Invoke-Pester` with the test file and the `-PassThru` option.

For example:

```
Invoke-Pester .\Install-OSServer.Tests.ps1 -PassThru
```

# Cleanup

You can remove the `Pester` module from the `PowerShell` by executing the following command:


```
Uninstall-Module Pester -AllVersions
```

You may need to close the `PowerShell` that was executing the tests.

Note: This will leave 3.4.0 which is the default by `PowerShell`
