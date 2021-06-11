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
