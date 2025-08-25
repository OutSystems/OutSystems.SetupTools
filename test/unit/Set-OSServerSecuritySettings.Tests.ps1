Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Set-OSServerSecuritySettings Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerVersion { return '11.23.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock RegWrite {}
        Mock SetWebConfigurationProperty { }

        $assRunRegWrite = @{ 'CommandName' = 'RegWrite'; 'Times' = 8; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunRegWrite = @{ 'CommandName' = 'RegWrite'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }
        $assRunSetWebConfigurationProperty = @{ 'CommandName' = 'SetWebConfigurationProperty'; 'Times' = 2; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunSetWebConfigurationProperty = @{ 'CommandName' = 'SetWebConfigurationProperty'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            Set-OSServerSecuritySettings -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run do anything' {
                Assert-MockCalled @assNotRunRegWrite
                Assert-MockCalled @assNotRunSetWebConfigurationProperty
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Set-OSServerSecuritySettings -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            Set-OSServerSecuritySettings -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run do anything' {
                Assert-MockCalled @assNotRunRegWrite
                Assert-MockCalled @assNotRunSetWebConfigurationProperty
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Set-OSServerSecuritySettings -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When there is an error disabling SSL' {

            Mock RegWrite { throw 'Error writting on registry' }
            $assRunRegWrite = @{ 'CommandName' = 'RegWrite'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

            Set-OSServerSecuritySettings -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run do RegWrite once' { Assert-MockCalled @assRunRegWrite }
            It 'Should not run anything else' { Assert-MockCalled @assNotRunSetWebConfigurationProperty }
            It 'Should output an error' { $err[-1] | Should Be 'Error disabling unsafe SSL protocols' }
            It 'Should not throw' { { Set-OSServerSecuritySettings -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When there is an error disabling clickjacking' {

            Mock SetWebConfigurationProperty { throw 'Error writting on IIS' }
            $assRunSetWebConfigurationProperty = @{ 'CommandName' = 'SetWebConfigurationProperty'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

            Set-OSServerSecuritySettings -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run disable SSL' { Assert-MockCalled @assRunRegWrite }
            It 'Should run Set-WebConfigurationProperty once' { Assert-MockCalled @assRunSetWebConfigurationProperty }
            It 'Should output an error' { $err[-1] | Should Be 'Error disabling click jacking' }
            It 'Should not throw' { { Set-OSServerSecuritySettings -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When everything runs successfully' {

            Set-OSServerSecuritySettings -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should configure everything' {
                Assert-MockCalled @assRunSetWebConfigurationProperty
                Assert-MockCalled @assRunRegWrite
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Set-OSServerSecuritySettings -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
