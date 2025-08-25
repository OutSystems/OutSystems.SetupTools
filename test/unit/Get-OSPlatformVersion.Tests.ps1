Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformVersion Tests' {

        # Global mocks
        Mock GetPlatformVersion { return "11.23.1" }

        Context 'When cannot connect to service center' {

            Mock GetPlatformVersion { throw "Error" }
            $result = Get-OSPlatformVersion -ServiceCenterHost 255.255.255.255 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result | Should Be $null
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error contacting service center or getting the platform version' }
            It 'Should not throw' { { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When can connect' {

            $result = Get-OSPlatformVersion -ServiceCenterHost 255.255.255.255 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result | Should Be '11.23.1'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
