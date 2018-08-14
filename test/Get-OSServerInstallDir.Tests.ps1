Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerInstallDir Tests' {

        Context 'When the platform server is not installed' {

            Mock GetServerInstallDir {
                Throw 'Cant find registry item'
            }

            It 'Should return an exception' {
               { Get-OSServerInstallDir } | Should Throw "Outsystems platform is not installed"
            }

        }

        Context 'When the platform server is installed' {

            Mock GetServerInstallDir {
                return 'C:\Program Files\OutSystems\Platform Server'
            }

            It 'Should return the install directory' {
                Get-OSServerInstallDir | Should Be 'C:\Program Files\OutSystems\Platform Server'
            }

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