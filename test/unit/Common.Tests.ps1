# This should be changed to import the OS DLLs directly and not importing the module
Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

. $PSScriptRoot\..\..\src\Outsystems.SetupTools\Lib\Common.ps1

Describe 'GetHashedPassword Tests' {
    Context 'Normal' {
        It 'Checks if returns a string' {
            GetHashedPassword -Password "MyPass" | Should BeLike "#*"
        }
    }
}

Describe 'MaskKey Tests' {
    Context 'Normal' {
        It 'Checks if returns a partial masked string' {
            MaskKey -Text "ThisIsTheSensitiveData" | Should BeLike "**********Data"
        }
        It 'Checks it does not fail on default values' {
            MaskKey | Should BeLike "**********"
        }
    }
}

Describe 'ValidateVersion Tests' {
    Context 'Normal' {
        It 'Major version does not match' {
            ValidateVersion -Version "12.0.0" -Major "11" -Minor "12" -Build "0" | Should Be $false
        }

        It 'Minor version is less than required' {
            ValidateVersion -Version "11.12.0" -Major "11" -Minor "23" -Build "0" | Should Be $false
        }

        It 'Build version is less than required' {
            ValidateVersion -Version "11.23.0" -Major "11" -Minor "23" -Build "1" | Should Be $false
        }

        It 'Build version is empty' {
            ValidateVersion -Version "" -Major "11" -Minor "23" -Build "1" | Should Be $true
        }

        It 'Version is acceptable' {
            ValidateVersion -Version "11.38.0" -Major "11" -Minor "23" -Build "0" | Should Be $true
        }
    }
}
