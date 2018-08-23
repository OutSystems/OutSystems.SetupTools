Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Disable-OSServerIPv6 Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock Get-NetAdapterBinding {}
        Mock Disable-NetAdapterBinding {}
        Mock New-ItemProperty {}

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Disable-OSServerIPv6 } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When theres an error disabling the IPv6' {

            Mock Get-NetAdapterBinding { throw "error" }
            Mock Disable-NetAdapterBinding { throw "error" }

            It 'Should return an exception' {
                { Disable-OSServerIPv6 } | Should throw "Error disabling IPv6"
            }

        }

        Context 'When everything is fine' {

            It 'Shouldnt throw anything' {
                { Disable-OSServerIPv6 } | Should Not throw
            }

            It 'Should run ok' {

                $assMParams = @{
                    'CommandName' = 'New-ItemProperty'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

    }
}
