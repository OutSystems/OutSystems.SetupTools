Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

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

        Context 'Can connect and get results using PSCredentials' {

            Mock GetPlatformServicesWS {
                $obj = [pscustomobject]@{}
                $obj | Add-Member -MemberType ScriptMethod -Name 'Modules_Get' -Force -Value {
                    param( [string]$SCUser, [string]$SCPass, [bool]$Dummy1, [bool]$Dummy2 )

                    if ($SCUser -eq 'SuperUser' -and $SCPass -eq 'SuperPass') {
                        return @{ 'Name' = 'MyModule'; 'Key' = 'c36e9646-0caf-4510-ad35-28a8b97c28b8' }
                    } else {
                        throw "Big error"
                    }
                }
                return $obj
            }

            Mock GetHashedPassword { return $SCPass }

            It 'Should get the app name' {
                $Credential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'SuperUser',('SuperPass' | ConvertTo-SecureString -AsPlainText -Force)
                $(Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -Credential $Credential).Name | Should Be "MyModule"
            }

            It 'Should get the app key' {
                $Credential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'SuperUser',('SuperPass' | ConvertTo-SecureString -AsPlainText -Force)
                $(Get-OSPlatformModules -ServiceCenterHost 255.255.255.255 -Credential $Credential).Key | Should Be "c36e9646-0caf-4510-ad35-28a8b97c28b8"
            }

        }
    }
}
