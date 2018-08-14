Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformVersion Tests' {

        Context 'When cannot connect to service center or the webservice returns error' {

            It 'Should throw an error' {
                { Get-OSPlatformVersion -Host 255.255.255.255 } | Should Throw "Error contacting service center"
            }

        }

        Context 'Can connect and get results' {

            Mock GetOutSystemsPlatformWS {
                $obj = [pscustomobject]@{}
                $obj | Add-Member -MemberType ScriptMethod -Name 'GetPlatformInfo' -Force -Value { '10.0.0.1' }
                return $obj
            }

            It 'Test the result if Service Center is reachable' {
                Get-OSPlatformVersion -Host csdevops-dev.outsystems.net | Should Be '10.0.0.1'
            }

        }
    }
}