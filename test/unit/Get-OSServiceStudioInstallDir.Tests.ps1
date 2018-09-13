Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioInstallDir Tests' {

        # Global mocks
        Mock GetServiceStudioInstallDir { return 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio' }

        Context 'When service studio is not installed' {

            Mock GetServiceStudioInstallDir { return $null }

            Get-OSServiceStudioInstallDir -MajorVersion '10.0' -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems development environment 10.0 is not installed' }
            It 'Should not throw' { { Get-OSServiceStudioInstallDir -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is installed' {

            It 'Should return the install directory' { Get-OSServiceStudioInstallDir -MajorVersion '10.0' | Should Be 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio' }
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
