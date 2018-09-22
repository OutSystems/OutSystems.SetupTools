Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformApplications Tests' {

        # Global mocks
        Mock GetApplications {
            $returnResult = [pscustomobject]@{
                Name = 'MyApp'
                Key  = 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            return $returnResult
        }

        Context 'When cannot connect to service center' {

            Mock GetApplications { throw "Error" }
            $result = Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result | Should Be $null
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error getting applications from 255.255.255.255' }
            It 'Should not throw' { { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When can connect and get results' {

            $result = Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255

            It 'Should return the right result' {
                $result.Name | Should Be 'MyApp'
                $result.Key | Should Be 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When -PassThru is specified' {

            $result = Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -PassThru

            It 'Should return the right result' {
                $result.ServiceCenterHost | Should Be '255.255.255.255'
                $result.Credential.UserName | Should Be 'admin'
                $result.Applications[0].Name | Should Be 'MyApp'
                $result.Applications[0].Key | Should Be 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }

        }
    }
}
