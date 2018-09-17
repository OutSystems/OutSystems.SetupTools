Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerInstallDir Tests' {

        # Global mocks
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }

        Context 'When platform is not installed' {

            Mock GetServerInstallDir { return $null }

            Get-OSServerInstallDir -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Get-OSServerInstallDir -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed' {

            It 'Should return the install directory' { Get-OSServerInstallDir | Should Be 'C:\Program Files\OutSystems\Platform Server' }
            It 'Should call the GetServerInstallDir only once' {

                $assMParams = @{
                    'CommandName' = 'GetServerInstallDir'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                 }
                 Assert-MockCalled @assMParams
            }
        }
    }
}
