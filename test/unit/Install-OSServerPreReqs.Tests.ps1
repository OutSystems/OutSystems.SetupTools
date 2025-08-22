Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServerPreReqs Tests' {
        #TODO installed / not installed console
        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = $Null; 'RebootNeeded' = $False } }
        Mock GetDotNet4Version { return $null }
        Mock GetDotNetHostingBundleVersions { return '0.0.0.0' }

        Mock InstallDotNet { return 0 }
        Mock InstallBuildTools { return 0 }
        Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 0 }; 'RestartNeeded' = @{ 'value__' = 1 }; 'Success' = $true } }
        Mock InstallDotNetHostingBundle { return 0 }
        Mock InstallDotNetCoreUninstallTool { }
        Mock IsDotNetCoreUninstallToolInstalled { return $false }
        Mock UninstallPreviousDotNetCorePackages { return $true }
        Mock ConfigureServiceWMI {}
        Mock ConfigureServiceWindowsSearch {}
        Mock DisableFIPS {}
        Mock ConfigureWindowsEventLog {}

        $assRunInstallDotNet = @{ 'CommandName' = 'InstallDotNet'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallDotNet = @{ 'CommandName' = 'InstallDotNet'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallBuildTools = @{ 'CommandName' = 'InstallBuildTools'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallBuildTools = @{ 'CommandName' = 'InstallBuildTools'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallWindowsFeatures = @{ 'CommandName' = 'InstallWindowsFeatures'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallWindowsFeatures = @{ 'CommandName' = 'InstallWindowsFeatures'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallDotNetHostingBundle8 = @{ 'CommandName' = 'InstallDotNetHostingBundle'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq "8" }}
        $assNotRunInstallDotNetHostingBundle8  = @{ 'CommandName' = 'InstallDotNetHostingBundle'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq "8" }}
        $assRunInstallDotNetHostingBundle = @{ 'CommandName' = 'InstallDotNetHostingBundle'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq "6" }}
        $assNotRunInstallDotNetHostingBundle  = @{ 'CommandName' = 'InstallDotNetHostingBundle'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq "6" }}
        $assRunInstallDotNetCoreUninstallTool = @{ 'CommandName' = 'InstallDotNetCoreUninstallTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallDotNetCoreUninstallTool = @{ 'CommandName' = 'InstallDotNetCoreUninstallTool'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureServiceWMI = @{ 'CommandName' = 'ConfigureServiceWMI'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureServiceWMI = @{ 'CommandName' = 'ConfigureServiceWMI'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureServiceWindowsSearch = @{ 'CommandName' = 'ConfigureServiceWindowsSearch'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureServiceWindowsSearch = @{ 'CommandName' = 'ConfigureServiceWindowsSearch'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunDisableFIPS = @{ 'CommandName' = 'DisableFIPS'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunDisableFIPS = @{ 'CommandName' = 'DisableFIPS'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 3; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}

        Context 'When installing OS 11 on a clean machine and everything succeed' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle }
            It 'Should not run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11 on a clean machine on or after 11.35 should not run build tools installation' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '35' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should not run the BuildTools installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '35' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11 on a clean machine and everything succeed with InstallMSBuildTools enabled' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '35' -ErrorVariable err -ErrorAction SilentlyContinue -InstallMSBuildTools $true

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '35' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11 with all prereqs installed' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'MS Build Tools 2015'; 'RebootNeeded' = $False } }
            Mock GetDotNet4Version { return 461808 }
            Mock GetDotNetHostingBundleVersions { return @('6.0.6', '8.0.0') }

            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the .NET installation' { Assert-MockCalled @assNotRunInstallDotNet }
            It 'Should not run the BuildToold installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should not run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11.38 on a clean machine and everything succeed' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -Minor '38' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should not run the BuildToold installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should not disable the FIPS' { Assert-MockCalled @assNotRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -Minor '38' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11.37 with all prereqs installed' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'MS Build Tools 2015'; 'RebootNeeded' = $False } }
            Mock GetDotNet4Version { return 461808 }
            Mock GetDotNetHostingBundleVersions { return @('6.0.6', '8.0.0') }

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '37' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the .NET installation' { Assert-MockCalled @assNotRunInstallDotNet }
            It 'Should not run the BuildToold installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should not run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle8 }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '37' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run anything' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assNotRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET installation fails to start' {

            Mock InstallDotNet { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the .NET installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the .NET installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET installer is not found' {

            Mock InstallDotNet { throw [System.IO.FileNotFoundException] '.NET installer not found' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be '.NET installer not found'
            }
            It 'Should output an error' { $err[-1] | Should Be '.NET installer not found' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET reports a reboot' {

            Mock InstallDotNet { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
            }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET reports an error' {

            Mock InstallDotNet { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing .NET 4.7.2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing .NET 4.7.2. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'Build tools versions are correctly validated' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2017' = $True; 'LatestVersionInstalled' = 'Build Tools 2017'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -InstallInfo (GetMSBuildToolsInstallInfo)

            It "All MS Build versions 2017 are supported in major version" {
                $result | Should Be $True
            }

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'Build Tools Update 3'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -InstallInfo (GetMSBuildToolsInstallInfo)

            It "All 2015 versions of MS Build are supported in major version" {
                $result | Should Be $True
            }

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2017' = $True; 'LatestVersionInstalled' = 'Build Tools 2017'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -InstallInfo (GetMSBuildToolsInstallInfo)

            It "All MS Build versions 2015 and 2017 are supported in major version" {
                $result | Should Be $True
            }
        }

        Context 'When build tools installation fails to start' {

            Mock InstallBuildTools { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the Build Tools installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the Build Tools installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When build tools installer not found' {

            Mock InstallBuildTools { throw [System.IO.FileNotFoundException] 'Build Tools installer not found' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Build Tools installer not found'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Build Tools installer not found' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When build tools a reboot' {

            Mock InstallBuildTools { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
            }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When build tools reports an error' {

            Mock InstallBuildTools { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing Build Tools 2015'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing Build Tools 2015. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features installation fails to start' {

            Mock InstallWindowsFeatures { throw 'Some error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error starting the windows features installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the windows features installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features reports a reboot' {

            Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 0 }; 'RestartNeeded' = @{ 'value__' = 2 }; 'Success' = $true} }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
            }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features reports an error' {

            Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 10 }; 'RestartNeeded' = @{ 'value__' = 1 }; 'Success' = $false} }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue


            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallWindowsFeatures
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing windows features'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing windows features. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 8.0 installation fails to start' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "8" } -MockWith { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle8
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the .NET 8.0 installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the .NET 8.0 installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 6.0 installation fails to start' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "6" } -MockWith { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the .NET 6.0 installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the .NET 6.0 installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 8.0 installer not found' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "8" } -MockWith { throw [System.IO.FileNotFoundException] '.NET 8.0 installer not found' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle8
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be '.NET 8.0 installer not found'
            }
            It 'Should output an error' { $err[-1] | Should Be '.NET 8.0 installer not found' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 6.0 installer not found' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "6" } -MockWith { throw [System.IO.FileNotFoundException] '.NET 6.0 installer not found' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be '.NET 6.0 installer not found'
            }
            It 'Should output an error' { $err[-1] | Should Be '.NET 6.0 installer not found' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 8.0 reports a reboot' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "8" } -MockWith { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle8
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
            }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 6.0 reports a reboot' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "6" } -MockWith { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
            }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 8.0 reports an error' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "8" } -MockWith { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle8
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing .NET 8.0 Windows Server Hosting bundle'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing .NET 8.0 Windows Server Hosting bundle. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET 6.0 reports an error' {

            Mock -CommandName InstallDotNetHostingBundle -ParameterFilter { $MajorVersion -eq "6" } -MockWith { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetHostingBundle
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing .NET 6.0 Windows Server Hosting bundle'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing .NET 6.0 Windows Server Hosting bundle. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure WMI reports an error' {

            Mock ConfigureServiceWMI { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }

            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring the WMI service'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring the WMI service' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure windows search reports an error' {

            Mock ConfigureServiceWindowsSearch { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }

            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring the Windows search service'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring the Windows search service' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure FIPS reports an error' {

            Mock DisableFIPS { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
            }

            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error disabling FIPS compliant algorithms checks'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error disabling FIPS compliant algorithms checks' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure Event Log reports an error' {

            Mock ConfigureWindowsEventLog { throw 'Big Error' }
            $assRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetHostingBundle
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
            }

            It 'Should NOT run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNetHostingBundle8
            }

            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring Security Event Log'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring Security Event Log' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version in Minor version 12 and Patch version 2 (11.12.2)' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '12' -PatchVersion '2' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Unsupported version'
            }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '12' -PatchVersion '2' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version in Minor version 27 and Patch version 0 (11.27.0)' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -PatchVersion '0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should not run the .NET Core Uninstall Tool installation' { Assert-MockCalled @assNotRunInstallDotNetCoreUninstallTool }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'OutSystems platform server pre-requisites successfully installed'
            }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -PatchVersion '0' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version in Minor version 27 and Patch version 0 (11.27.0) with RemovePreviousHostingBundlePackages flag active' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -PatchVersion '0' -RemovePreviousHostingBundlePackages $true -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should run the .NET Core Uninstall Tool installation' { Assert-MockCalled @assRunInstallDotNetCoreUninstallTool }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'OutSystems platform server pre-requisites successfully installed'
            }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -PatchVersion '0' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version without passing the optional Minor and Patch Versions' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle }
            It 'Should not run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle8 }
            It 'Should not run the .NET Core Uninstall Tool installation' { Assert-MockCalled @assNotRunInstallDotNetCoreUninstallTool }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'OutSystems platform server pre-requisites successfully installed'
            }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version without passing the optional Minor and Patch Versions and with RemovePreviousHostingBundlePackages flag active' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -RemovePreviousHostingBundlePackages $true -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildTools installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle }
            It 'Should not run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle8 }
            It 'Should run the .NET Core Uninstall Tool installation' { Assert-MockCalled @assRunInstallDotNetCoreUninstallTool }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'OutSystems platform server pre-requisites successfully installed'
            }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install prerequisites for a OS 11 version in Minor version 38 and Patch version 0 (11.38.0), it should not disable FIPS' {

            $result = Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '38' -PatchVersion '0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should not run the BuildTools installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET 6.0 Hosting Bundle installation' { Assert-MockCalled @assNotRunInstallDotNetHostingBundle }
            It 'Should run the .NET 8.0 Hosting Bundle installation' { Assert-MockCalled @assRunInstallDotNetHostingBundle8 }
            It 'Should not run the .NET Core Uninstall Tool installation' { Assert-MockCalled @assNotRunInstallDotNetCoreUninstallTool }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should not disable the FIPS' { Assert-MockCalled @assNotRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'OutSystems platform server pre-requisites successfully installed'
            }

            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11' -MinorVersion '38' -PatchVersion '0' -ErrorVariable err -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
