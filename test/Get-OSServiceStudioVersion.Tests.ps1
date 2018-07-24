Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioVersion Tests' {

        Context 'Service Studio not installed' {
            It 'Service Studio 1.0 not installed' {
               { Get-OSServiceStudioVersion -MajorVersion '1.0' } | Should Throw "Outsystems development environment 1.0 is not installed"
            }
        }

        Context 'Service Studio installed' {
            Mock GetServiceStudioVersion { return '10.0.822.0' }
            It 'Service Studio 10 installed' {
                Get-OSServiceStudioVersion -MajorVersion '10.0' | Should Be '10.0.822.0'
            }
        }
    }
}