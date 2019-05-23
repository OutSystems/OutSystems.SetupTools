Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSolutionPack Tests' {

        # Global mocks
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock PublishSolution { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock SetSysComponentsCompiledVersion {}

        $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "admin" -and $SCPass -eq "admin" } }
        $assNotRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $result = Publish-OSPlatformSolutionPack -Solution "hi" -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems platform is not installed'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi" -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center is not installed or has a wrong version' {

            Mock GetSCCompiledVersion { return $null }

            $result = Publish-OSPlatformSolutionPack -Solution "hi" -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When a solution and the platform dont have the same version' {

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When a solution is not installed' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When a solution and platform have the same version' {

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Solution successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error launching the publish solution' {

            Mock GetSysComponentsCompiledVersion { return $null }
            Mock PublishSolution { throw "Error" }

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error lauching the solution installion'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error lauching the solution installion' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error installing a solution' {

            Mock GetSysComponentsCompiledVersion { return $null }
            Mock PublishSolution { return @{ 'Output' = 'NOT good'; 'ExitCode' = 1} }

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.ExitCode | Should Be 1
                $result.Message | Should Be 'Error installing the solution'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the solution. Return code: 1' }
            It 'Should not throw' { { Publish-OSPlatformSolutionPack -Solution "hi"  -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When ServiceCenterUser is specified' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $result = Publish-OSPlatformSolutionPack -Solution "hi"  -ServiceCenterUser 'Whatever' -ErrorVariable err -ErrorAction SilentlyContinue

            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
        }

        Context 'When credentials are specified' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $cred = New-Object System.Management.Automation.PSCredential ("Whatever", $(ConvertTo-SecureString "admin" -AsPlainText -Force))

            $result = Publish-OSPlatformSolutionPack -Solution "hi" -Credential $cred -ErrorVariable err -ErrorAction SilentlyContinue

            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
        }
    }
}
