Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerVersion Tests' {

        Context 'When is not possible to check the platform server version' {

            Mock GetServerVersion {
                throw "Unknow error"
            }

            It 'Should return an exception' {
                { Get-OSServerVersion } | Should throw "Error checking for Outsystems version"
            }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion {
                return $null
            }

            It 'Should return an exception' {
                { Get-OSServerVersion } | Should throw "Outsystems platform is not installed"
            }

        }

        Context 'When the platform server is installed' {

            Mock GetServerVersion {
                return '10.0.0.0'
            }

            It 'Should return the version' {
                Get-OSServerVersion | Should Be '10.0.0.0'
            }

            It 'Should call the GetServerVersion only once' {

                $assMParams = @{
                    'CommandName' = 'GetServerVersion'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }
        }
    }
}
