Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Start-OSServerServices Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}

        Context 'When user is not admin' {
            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should throw exception' {
                { Start-OSServerServices } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }
        }

    }
}
