# This should be changed to import the OS DLLs directly and not importing the module
Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

. $PSScriptRoot\..\..\src\Outsystems.SetupTools\Lib\WebServicesFunctions.ps1
. $PSScriptRoot\..\..\src\Outsystems.SetupTools\Lib\CommonFunctions.ps1

Describe 'GetHashedPassword Tests' {
    Context 'Normal' {
        It 'Checks if returns a string' {
            GetHashedPassword -SCPassword "MyPass" | Should BeLike "#*"
        }
    }
}
