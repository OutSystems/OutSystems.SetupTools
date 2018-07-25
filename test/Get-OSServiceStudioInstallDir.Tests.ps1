Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioInstallDir Tests' {

        Context 'Real GetServiceStudioInstallDir' {

            It 'Checks that Service Studio 1.0 is not installed' {
               { Get-OSServiceStudioInstallDir -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }

        }

        Context 'Mocked GetServiceStudioInstallDir' {

            Mock GetServiceStudioInstallDir {
                return 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio'
            }

            It 'Checks that Service Studio 10 installed' {
                Get-OSServiceStudioInstallDir -MajorVersion '10.0' | Should Be 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio'
            }

            It 'Checks that GetServiceStudioInstallDir is called only once' {

                $assMParams = @{
                    'CommandName' = 'GetServiceStudioInstallDir'
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