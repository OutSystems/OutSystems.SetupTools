Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioVersion Tests' {

        Context 'When service studio is not installed' {

            Mock GetServiceStudioVersion {
                Throw 'Cant find registry item'
            }

            It 'Should return an exception' {
               { Get-OSServiceStudioVersion -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }

        }

        Context 'When service studio is installed' {

            Mock GetServiceStudioVersion { return '10.0.822.0' }

            It 'Should return the version' {
                Get-OSServiceStudioVersion -MajorVersion '10.0' | Should Be '10.0.822.0'
            }

            It 'Should call the GetServiceStudioInstallDir only once' {

                $assMParams = @{
                    'CommandName' = 'GetServiceStudioVersion'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                    'ParameterFilter' = { $MajorVersion -eq '10.0' }
                 }

                 Assert-MockCalled @assMParams
            }
        }
    }
}