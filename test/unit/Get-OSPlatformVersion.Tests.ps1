Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformVersion Tests' {

        Mock GetOutSystemsPlatformWS {
            $obj = [pscustomobject]@{}
            $obj | Add-Member -MemberType ScriptMethod -Name 'GetPlatformInfo' -Force -Value { '10.0.0.1' }
            return $obj
        }

        Context 'When cannot connect to service center or the webservice returns error' {

            Mock GetOutSystemsPlatformWS {
                $obj = [pscustomobject]@{}
                $obj | Add-Member -MemberType ScriptMethod -Name 'GetPlatformInfo' -Force -Value { throw 'Big error' }
                return $obj
            }

            Get-OSPlatformVersion -Host 255.255.255.255 -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error contacting service center or getting the platform version' }
            It 'Should not throw' { { Get-OSPlatformVersion -Host 255.255.255.255 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When can connect' {
            It 'Should get the platform version' { Get-OSPlatformVersion -Host csdevops-dev.outsystems.net | Should Be '10.0.0.1' }

        }

    }
}
