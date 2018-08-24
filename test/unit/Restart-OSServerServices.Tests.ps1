Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Restart-OSServerServices Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock Get-Service { [PSCustomObject]@{ Name = 'OutSystems Log Service'; Status = 'Running'; StopType = 'Automatic' } }
        Mock Restart-Service {}

        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
        $OSServices = @( "OutSystems Log Service" )

        Context 'When user is not admin' {
            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should throw exception' {
                { Restart-OSServerServices } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }
        }

        Context 'When the service is successfully restarted' {

            It 'Should not throw' {
                { Restart-OSServerServices } | Should Not throw
            }

            It 'Should call Get-Service twice' {
                $assMParams = @{
                    'CommandName' = 'Get-Service'
                    'Times' = 2
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }

            It 'Should call Restart-Service once' {
                $assMParams = @{
                    'CommandName' = 'Restart-Service'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }
        }

        Context 'When the service is disabled' {

            Mock Get-Service { [PSCustomObject]@{ Name = 'OutSystems Log Service'; Status = 'Stopped'; StartType = 'Disabled' } }

            It 'Should not throw' {
                { Restart-OSServerServices } | Should Not throw
            }

            It 'Should call Get-Service once' {
                $assMParams = @{
                    'CommandName' = 'Get-Service'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }

            It 'Should not call Restart-Service' {
                $assMParams = @{
                    'CommandName' = 'Restart-Service'
                    'Times' = 0
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }
        }

        Context 'When the service doesnt exist' {

            Mock Get-Service { }

            It 'Should not throw' {
                { Restart-OSServerServices } | Should Not throw
            }

            It 'Should call Get-Service once' {
                $assMParams = @{
                    'CommandName' = 'Get-Service'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }

            It 'Should not call Stop-Service' {
                $assMParams = @{
                    'CommandName' = 'Restart-Service'
                    'Times' = 0
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }
        }

        Context 'When theres an error restarting the service' {
            Mock Restart-Service { throw "Error" }

            It 'Should throw exception' {
                { Restart-OSServerServices } | Should throw "Error restarting the service OutSystems Log Service"
            }
        }

    }
}
