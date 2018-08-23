Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'New-OSPlatformPrivateKey Tests' {

        Mock GenerateEncryptKey { return '#key123' }

        Context 'When there is an error generating the key' {

            Mock GenerateEncryptKey { throw "Whatever" }

            It 'Should return an exception' {
                { New-OSPlatformPrivateKey } | Should throw "Error generating a new private key"
            }
        }

        Context 'When the key is generated successfully' {

            It 'Should return the key' {
                New-OSPlatformPrivateKey | Should Be '#key123'
            }
        }
    }
}
