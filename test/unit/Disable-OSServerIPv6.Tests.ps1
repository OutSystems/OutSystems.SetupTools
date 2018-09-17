Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Disable-OSServerIPv6 Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock Get-NetAdapterBinding {}
        Mock Disable-NetAdapterBinding {}
        Mock RegWrite {}

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            Disable-OSServerIPv6 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Disable-OSServerIPv6 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error disabling the IPv6' {

            Mock Get-NetAdapterBinding { throw "error" }
            Mock Disable-NetAdapterBinding { throw "error" }

            Disable-OSServerIPv6 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should output an error' { $err[-1] | Should Be 'Error disabling IPv6' }
            It 'Should not throw' { { Disable-OSServerIPv6 -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When everything is fine' {

            Disable-OSServerIPv6 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Disable-OSServerIPv6 -ErrorAction SilentlyContinue } | Should Not throw }

        }

    }
}
