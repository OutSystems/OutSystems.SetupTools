Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioInstallDir Tests' {

        Context 'When service studio is not installed' {

            Mock GetServiceStudioInstallDir {
                Throw 'Cant find registry item'
            }

            It 'Should return an exception' {
               { Get-OSServiceStudioInstallDir -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }

        }

        Context 'When service studio is installed' {

            Mock GetServiceStudioInstallDir {
                return 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio'
            }

            It 'Should return the install directory' {
                Get-OSServiceStudioInstallDir -MajorVersion '10.0' | Should Be 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio'
            }

            It 'Should call the GetServiceStudioInstallDir only once' {

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