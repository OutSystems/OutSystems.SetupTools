Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioVersion Tests' {

        # Global mocks
        Mock GetServiceStudioVersion { return '11.55.35.0' }

        Context 'When service studio is not installed' {

            Mock GetServiceStudioVersion { return $null }

            Get-OSServiceStudioVersion -MajorVersion '11.0' -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems development environment 11.0 is not installed' }
            It 'Should not throw' { { Get-OSServiceStudioVersion -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is installed' {

            It 'Should return the version' { Get-OSServiceStudioVersion -MajorVersion '11.0' | Should Be '11.55.35.0' }
            It 'Should call the GetServiceStudioInstallDir only once' {

                $assMParams = @{
                    'CommandName' = 'GetServiceStudioVersion'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                    'ParameterFilter' = { $MajorVersion -eq '11.0' }
                 }
                 Assert-MockCalled @assMParams
            }
        }
    }
}
