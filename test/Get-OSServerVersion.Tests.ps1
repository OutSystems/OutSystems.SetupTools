Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerVersion Tests' {

        Context 'When the platform server is not installed' {

            Mock GetServerVersion {
                Throw 'Cant find registry item'
            }

            It 'Should return an exception' {
               { Get-OSServerVersion } | Should Throw "Outsystems platform is not installed"
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
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                 }

                 Assert-MockCalled @assMParams
            }
        }
    }
}