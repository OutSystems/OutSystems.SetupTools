Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformApplications Tests' {

        Context 'When cannot connect to service center or the webservice returns error' {

            Mock GetPlatformServicesWS { Throw "Error" }

            It 'Should throw an error' {
                { Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin" } | Should Throw "Error getting applications"
            }

        }

        Context 'Can connect and get results' {

            Mock GetPlatformServicesWS {
                $obj = [pscustomobject]@{}
                $obj | Add-Member -MemberType ScriptMethod -Name 'Applications_Get' -Force -Value { @{ 'Name' = 'MyApp'; 'Key' = 'c36e9646-0caf-4510-ad35-28a8b97c28b8' } }
                return $obj
            }

            It 'Should get the app name' {
                $(Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin").Name | Should Be "MyApp"
            }

            It 'Should get the app key' {
                $(Get-OSPlatformApplications -ServiceCenterHost 255.255.255.255 -ServiceCenterUser "admin" -ServiceCenterPass "admin").Key | Should Be "c36e9646-0caf-4510-ad35-28a8b97c28b8"
            }

        }
    }
}