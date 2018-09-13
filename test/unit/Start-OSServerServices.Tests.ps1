Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Start-OSServerServices Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock Get-Service { [PSCustomObject]@{ Name = 'OutSystems Log Service'; Status = 'Running'; StartType = 'Automatic' } }
        Mock Start-Service {}

        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
        $OSServices = @( "OutSystems Log Service" )

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }

            $assRunGetService = @{ 'CommandName' = 'Get-Service'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }
            $assRunStartService = @{ 'CommandName' = 'Start-Service'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

            Start-OSServerServices -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not call Get-Services' { Assert-MockCalled @assRunGetService }
            It 'Should not call Start-Services' { Assert-MockCalled @assRunStartService }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Start-OSServerServices -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service is successfully started' {

            $assRunGetService = @{ 'CommandName' = 'Get-Service'; 'Times' = 2; 'Exactly' = $true; 'Scope' = 'Context' }
            $assRunStartService = @{ 'CommandName' = 'Start-Service'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

            Start-OSServerServices -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call Get-Services' { Assert-MockCalled @assRunGetService }
            It 'Should call Start-Services' { Assert-MockCalled @assRunStartService }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Start-OSServerServices -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service is disabled' {

            Mock Get-Service { [PSCustomObject]@{ Name = 'OutSystems Log Service'; Status = 'Stopped'; StartType = 'Disabled' } }

            $assRunGetService = @{ 'CommandName' = 'Get-Service'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
            $assRunStartService = @{ 'CommandName' = 'Start-Service'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

            Start-OSServerServices -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call Get-Services' { Assert-MockCalled @assRunGetService }
            It 'Should call Start-Services' { Assert-MockCalled @assRunStartService }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Start-OSServerServices -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service doesnt exist' {

            Mock Get-Service { }

            $assRunGetService = @{ 'CommandName' = 'Get-Service'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
            $assRunStartService = @{ 'CommandName' = 'Start-Service'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

            Start-OSServerServices -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call Get-Services' { Assert-MockCalled @assRunGetService }
            It 'Should call Start-Services' { Assert-MockCalled @assRunStartService }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Start-OSServerServices -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error starting the service' {

            Mock Start-Service { throw "Error" }

            $assRunGetService = @{ 'CommandName' = 'Get-Service'; 'Times' = 2; 'Exactly' = $true; 'Scope' = 'Context' }
            $assRunStartService = @{ 'CommandName' = 'Start-Service'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

            Start-OSServerServices -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call Get-Services' { Assert-MockCalled @assRunGetService }
            It 'Should call Start-Services' { Assert-MockCalled @assRunStartService }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the service OutSystems Log Service' }
            It 'Should not throw' { { Start-OSServerServices -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
