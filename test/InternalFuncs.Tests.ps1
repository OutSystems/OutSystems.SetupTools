Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

. $PSScriptRoot\..\src\Outsystems.SetupTools\Lib\InternalFuncs.ps1

Describe 'GetHashedPassword Tests' {
    Context 'Normal' {
        It 'Checks if returns a string' {
            GetHashedPassword -SCPassword "MyPass" | Should BeLike "#*"
        }
    }
}