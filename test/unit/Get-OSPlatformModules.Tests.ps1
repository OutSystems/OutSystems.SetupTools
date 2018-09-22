Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformModules Tests' {

        # Global mocks
        Mock GetModules {
            $returnResult = [pscustomobject]@{
                Name = 'MyModule'
                Key  = 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            return $returnResult
        }

        Context 'When cannot connect to service center' {

            Mock GetModules { throw "Error" }
            $result = Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result | Should Be $null
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error getting modules from 255.255.255.255' }
            It 'Should not throw' { { Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When can connect and get results' {

            $result = Get-OSPlatformModules -ServiceCenterHost 255.255.255.255

            It 'Should return the right result' {
                $result.Name | Should Be 'MyModule'
                $result.Key | Should Be 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When -PassThru is specified' {

            $result = Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -PassThru

            It 'Should return the right result' {
                $result.ServiceCenterHost | Should Be '255.255.255.255'
                $result.Credential.UserName | Should Be 'admin'
                $result.Modules[0].Name | Should Be 'MyModule'
                $result.Modules[0].Key | Should Be 'c36e9646-0caf-4510-ad35-28a8b97c28b8'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }

        }
    }
}
