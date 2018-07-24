Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioInstallDir Tests' {

        Context 'Service Studio not installed' {
            It 'Service Studio 1.0 not installed' {
               { Get-OSServiceStudioInstallDir -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }
        }

        Context 'Service Studio installed' {
            Mock GetServiceStudioInstallDir { return 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio' }
            It 'Service Studio 10 installed' {
                Get-OSServiceStudioInstallDir -MajorVersion '10.0' | Should Be 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio'
            }
        }
    }
}