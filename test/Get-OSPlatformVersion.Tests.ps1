Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformVersion Tests' {

        Context 'Real WebServiceProxy' {

            It 'Test the result when Service Center is NOT reachable' {
                { Get-OSPlatformVersion -Host 255.255.255.255 } | Should Throw "Error contacting service center"
            }

        }

        Context 'Mocked WebServiceProxy' {

            Mock New-WebServiceProxy {
                $obj = New-MockObject -Type 'System.Web.Services.Protocols.SoapHttpClientProtocol'
                $obj | Add-Member -MemberType ScriptMethod -Name 'GetPlatformInfo' -Force -Value { '10.0.0.1' }
                return $obj
            }

            It 'Test the result if Service Center is reachable' {
                Get-OSPlatformVersion -Host csdevops-dev.outsystems.net | Should Be '10.0.0.1'
            }

        }
    }
}