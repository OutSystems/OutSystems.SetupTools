Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformServerPrivateKey Tests' {

        # private.key file
        $filecontent = '--WARNING: this file contains your private encryption key. This key is your personal#'
        $filecontent += '--confidential information and must not be shared with anyone. Under no circumstances#'
        $filecontent += '--should you give access to your encryption key to other people. No OutSystems employee#'
        $filecontent += '--will ever ask you to provide this encryption key. This key is not and will never be necessary#'
        $filecontent += '--to carry a successful interaction with OutSystems employees (e.g. support scenarios).#'
        $filecontent += 'v4iwANAsGDRpjiEpO8Kt3Q=='
        $filecontent = $filecontent.Split('#')

        # Global mocks
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock Test-Path { return $true }
        Mock Get-Content { return $filecontent }

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

        Context 'When the private key is valid' {

            It 'Should not throw any errors' {
                { Get-OSPlatformServerPrivateKey } | Should Not throw
            }

            It 'Should return the private key' {
                Get-OSPlatformServerPrivateKey | Should Be 'v4iwANAsGDRpjiEpO8Kt3Q=='
            }

        }

        Context 'When the private key is invalid' {

            Mock Get-Content { return '--' }

            It 'Should throw an exception' {
                { Get-OSPlatformServerPrivateKey } | Should throw
            }

        }
    }
}
