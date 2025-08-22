Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSolutionPack Tests' {

        # Global mocks
        Mock PublishSolution { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock GetServerVersion { return '11.23.0.0' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }

        $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "admin" -and $SCPass -eq "admin" } }
        $assNotRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy" -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems platform is not installed'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy" -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the solution installation succeeds' {

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error launching the publish solution' {

            Mock PublishSolution { throw "Error" }

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error lauching the solution installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error lauching the solution installation' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error installing a solution' {

            Mock PublishSolution { return @{ 'Output' = 'NOT good'; 'ExitCode' = 1} }

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be 1
                $result.Message | Should Be 'Error installing the solution'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the solution. Return code: 1' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When ServiceCenterUser is specified' {

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ServiceCenterUser 'Whatever' -ErrorVariable err -ErrorAction SilentlyContinue
            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When credentials are specified' {

            $cred = New-Object System.Management.Automation.PSCredential ("Whatever", $(ConvertTo-SecureString "admin" -AsPlainText -Force))

            $result = Publish-OSPlatformSolutionPack -Solution "solutionDummy" -Credential $cred -ErrorVariable err -ErrorAction SilentlyContinue
            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "solutionDummy"  -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
