Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioVersion Tests' {

        Context 'Real GetServiceStudioVersion' {

            It 'Checks that Service Studio 1.0 not installed' {
               { Get-OSServiceStudioVersion -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }

        }

        Context 'Mocked GetServiceStudioVersion' {

            Mock GetServiceStudioVersion { return '10.0.822.0' }

            It 'Checks that Service Studio 10 installed' {
                Get-OSServiceStudioVersion -MajorVersion '10.0' | Should Be '10.0.822.0'
            }

            It 'Checks that GetServiceStudioInstallDir is called only once' {

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