Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformServerPrivateKey Tests' {

        # Global mocks
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }

        Context 'When platform is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            It 'Should throw an exception' {
                { Get-OSPlatformServerPrivateKey } | Should throw "Outsystems platform is not installed"
            }

        }

        Context 'When the private key is not present' {

            Mock Test-Path { return $false }

            It 'Should throw an exception' {
                { Get-OSPlatformServerPrivateKey } | Should throw "Cant find the private key at C:\Program Files\OutSystems\Platform Server\private.key"
            }

        }
    }
}
