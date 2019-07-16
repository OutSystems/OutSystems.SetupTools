Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioVersion Tests' {

        # Global mocks
        Mock GetServiceStudioVersion { return '10.0.822.0' }

        Context 'When service studio is not installed' {

            Mock GetServiceStudioVersion { return $null }

            Get-OSServiceStudioVersion -MajorVersion '10' -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems development environment 10 is not installed' }
            It 'Should not throw' { { Get-OSServiceStudioVersion -MajorVersion '10' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is installed' {

            It 'Should return the version' { Get-OSServiceStudioVersion -MajorVersion '10' | Should Be '10.0.822.0' }
            It 'Should call the GetServiceStudioInstallDir only once' {

                $assMParams = @{
                    'CommandName' = 'GetServiceStudioVersion'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                    'ParameterFilter' = { $MajorVersion -eq '10' }
                 }
                 Assert-MockCalled @assMParams
            }
        }
    }
}
