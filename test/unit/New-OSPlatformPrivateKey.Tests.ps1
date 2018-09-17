Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'New-OSPlatformPrivateKey Tests' {

        # Global mocks
        Mock GenerateEncryptKey { return '#key123' }

        Context 'When there is an error generating the key' {

            Mock GenerateEncryptKey { throw "Whatever" }

            New-OSPlatformPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error generating a new private key' }
            It 'Should not throw' { { New-OSPlatformPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the key is generated successfully' {

            $result = New-OSPlatformPrivateKey -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should report the right result' { $result | Should Be '#key123' }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { New-OSPlatformPrivateKey -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
