Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServiceStudioInfo Tests' {

        # Global mocks
        Mock GetServiceStudioVersion { return '10.0.822.0' }
        Mock GetServiceStudioInstallDir { return 'C:\Program Files\OutSystems\Development Environment 10.0\Service Studio' }

        $assGetServiceStudioVersion = @{ 'CommandName' = 'GetServiceStudioVersion'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq '10.0' }}
        $assGetServiceStudioInstallDir = @{ 'CommandName' = 'GetServiceStudioInstallDir'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $MajorVersion -eq '10.0' }}

        Context 'When service studio is not installed' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServiceStudioInstallDir { return $null }

            Get-OSServiceStudioInfo -MajorVersion '10.0' -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems development environment 10.0 is not installed' }
            It 'Should not throw' { { Get-OSServiceStudioVersion -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is installed' {

            $output = Get-OSServiceStudioInfo -MajorVersion '10.0' -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should return the version' { $output.Version | Should Be '10.0.822.0' }
            It 'Should call the GetServiceStudioVersion' { Assert-MockCalled @assGetServiceStudioVersion }
            It 'Should call the GetServiceStudioInstallDir' { Assert-MockCalled @assGetServiceStudioInstallDir }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServiceStudioVersion -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
