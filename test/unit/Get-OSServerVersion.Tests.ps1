Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerVersion Tests' {

        # Global mocks
        Mock GetServerVersion { return '10.0.0.0' }

        Context 'When platform is not installed' {

            Mock GetServerVersion { return $null }

            Get-OSServerVersion -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Get-OSServerVersion -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed' {

            It 'Should return the version' { Get-OSServerVersion | Should Be '10.0.0.0' }
            It 'Should call the GetServerVersion only once' {

                $assMParams = @{
                    'CommandName' = 'GetServerVersion'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }
                Assert-MockCalled @assMParams
            }
        }
    }
}
