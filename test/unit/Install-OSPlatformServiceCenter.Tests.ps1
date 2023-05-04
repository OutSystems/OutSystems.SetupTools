Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSPlatformServiceCenter Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock RunSCInstaller { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock SetSCCompiledVersion {}

        $assRunSCInstaller = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunSCInstaller = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems platform is not installed'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center and the platform dont have the same version' {

            Mock GetSCCompiledVersion { return '10.0.0.0' }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service center successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center is not installed' {

            Mock GetSCCompiledVersion { return $null }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service center successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center and platform have the same version' {

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service center successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center and platform have the same version but the force switch is specified' {

            $result = Install-OSPlatformServiceCenter -Force -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service center successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error launching the scinstaller' {

            Mock GetSCCompiledVersion { return $null }
            Mock RunSCInstaller { throw "Error lauching the scinstaller" }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error lauching the service center installer'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error lauching the service center installer' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error installing service center' {

            Mock GetSCCompiledVersion { return $null }
            Mock RunSCInstaller { return @{ 'Output' = 'NOT good'; 'ExitCode' = 1} }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 1
                $result.Message | Should Be 'Error installing service center'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing service center. Return code: 1' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform is the version 10' {

            Mock GetServerVersion { return '10.0.0.1' }
            Mock GetSCCompiledVersion { return $null }

            Install-OSPlatformServiceCenter | Out-Null

            It 'Should run the RunSCInstaller with specific parameters' {
                $assMParams = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif" }}
                Assert-MockCalled @assMParams
            }
        }

        Context 'When the platform is the version 11' {

            Mock GetServerVersion { return '11.0.0.1' }
            Mock GetSCCompiledVersion { return $null }

            Install-OSPlatformServiceCenter | Out-Null

            It 'Should run the RunSCInstaller with specific parameters' {
                $assParams = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 1; 'Exactly' = $true;'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif PlatformLogs.xif" }}
                Assert-MockCalled @assParams
            }
        }

        Context 'When the platform is the version 11.18.1' {

            Mock GetServerVersion { return '11.18.1.1' }
            Mock GetSCCompiledVersion { return $null }

            Install-OSPlatformServiceCenter | Out-Null

            It 'Should run the RunSCInstaller with specific parameters' {
                $assParams = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 1; 'Exactly' = $true;'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif PlatformLogs.xif CentralizedPlatformLogs.xif" }}
                Assert-MockCalled @assParams
            }
        }

        Context 'When the platform is the version 12' {

            Mock GetServerVersion { return '12.0.0.1' }
            Mock GetSCCompiledVersion { return $null }

            Install-OSPlatformServiceCenter | Out-Null

            It 'Should run the RunSCInstaller with specific parameters' {
                $assParams = @{ 'CommandName' = 'RunSCInstaller'; 'Times' = 1; 'Exactly' = $true;'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif PlatformLogs.xif CentralizedPlatformLogs.xif" }}
                Assert-MockCalled @assParams
            }
        }

        Context 'When the platform is an unsupported version' {

            Mock GetServerVersion { return '9.0.0.1' }
            Mock GetSCCompiledVersion { return $null }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Unsupported Outsystems platform version'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Unsupported Outsystems platform version' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error setting the service center version' {

            Mock GetSCCompiledVersion { return $null }
            Mock SetSCCompiledVersion { throw 'Error' }

            $result = Install-OSPlatformServiceCenter -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunSCInstaller }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error setting the service center version'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error setting the service center version' }
            It 'Should not throw' { { Install-OSPlatformServiceCenter -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
