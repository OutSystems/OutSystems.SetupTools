Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformModules Tests' {

        Context 'When cannot connect to service center or the webservice returns error' {

            Mock GetPlatformServicesWS { Throw "Error" }

            It 'Should throw an error' {
                { Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin" } | Should Throw "Error getting modules"
            }

        }

        Context 'Can connect and get results' {

            Mock GetPlatformServicesWS {
                $obj = [pscustomobject]@{}
                $obj | Add-Member -MemberType ScriptMethod -Name 'Modules_Get' -Force -Value { @{ 'Name' = 'MyModule'; 'Key' = 'c36e9646-0caf-4510-ad35-28a8b97c28b8' } }
                return $obj
            }

            It 'Should get the module name' {
                $(Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin").Name | Should Be "MyModule"
            }

            It 'Should get the module key' {
                $(Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin").Key | Should Be "c36e9646-0caf-4510-ad35-28a8b97c28b8"
            }

        }
    }
}