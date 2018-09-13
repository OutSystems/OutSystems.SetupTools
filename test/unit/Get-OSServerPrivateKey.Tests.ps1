Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerPrivateKey Tests' {

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

            Get-OSServerPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Get-OSServerPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the private key is not present' {

            Mock Test-Path { return $false }

            Get-OSServerPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Cant find the private key at C:\Program Files\OutSystems\Platform Server\private.key' }
            It 'Should not throw' { { Get-OSServerPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the private key is valid' {

            $result = Get-OSServerPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should return the private key' { $result | Should Be 'v4iwANAsGDRpjiEpO8Kt3Q==' }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServerPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the private key is invalid' {

            Mock Get-Content { return '--' }

            Get-OSServerPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error processing the file' }
            It 'Should not throw' { { Get-OSServerPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When there is an exception' {

            Mock Get-Content { throw 'Something bad' }

            Get-OSServerPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Unknown fatal error' }
            It 'Should not throw' { { Get-OSServerPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
