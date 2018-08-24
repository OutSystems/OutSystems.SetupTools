Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Stop-OSServerServices Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock Get-Service { [PSCustomObject]@{ Name = 'OutSystems Log Service'; Status = 'Running'; StopType = 'Automatic' } }
        Mock Stop-Service {}

        $OSServices = @( "OutSystems Log Service" )

        Context 'When user is not admin' {
            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should throw exception' {
                { Stop-OSServerServices } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }
        }

        Context 'When the service is successfully stopped or is already stopped' {

            It 'Should not throw' {
                { Stop-OSServerServices } | Should Not throw
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

            It 'Should call Stop-Service once' {
                $assMParams = @{
                    'CommandName' = 'Stop-Service'
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
                { Stop-OSServerServices } | Should Not throw
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
                    'CommandName' = 'Stop-Service'
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
                { Stop-OSServerServices } | Should Not throw
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
                    'CommandName' = 'Stop-Service'
                    'Times' = 0
                    'Exactly' = $true
                    'Scope' = 'Context'
                }
                Assert-MockCalled @assMParams
            }
        }

        Context 'When theres an error Stoping the service' {
            Mock Stop-Service { throw "Error" }

            It 'Should throw exception' {
                { Stop-OSServerServices } | Should throw "Error stopping the service OutSystems Log Service"
            }
        }

    }
}
