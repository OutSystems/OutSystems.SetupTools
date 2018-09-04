Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSystemComponents Tests' {

        # Global mocks
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock GetSysComponentsCompiledVersion { return '10.0.0.1' }
        Mock PublishSolution { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock SetSysComponentsCompiledVersion {}

        $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "admin" -and $SCPass -eq "admin" } }
        $assNotRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems platform is not installed'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center is not installed or has a wrong version' {

            Mock GetSCCompiledVersion { return $null }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first' }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When system components and the platform dont have the same version' {

            Mock GetSysComponentsCompiledVersion { return '10.0.0.0' }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems system components successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When system components is not installed' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems system components successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When system components and platform have the same version' {

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunPublishSolution}
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems system components successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When system components and platform have the same version but the force switch is specified' {

            $result = Publish-OSPlatformSystemComponents -Force -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems system components successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error launching the publish solution' {

            Mock GetSysComponentsCompiledVersion { return $null }
            Mock PublishSolution { throw "Error" }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error lauching the system components installer'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error lauching the system components installer' }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error installing system components' {

            Mock GetSysComponentsCompiledVersion { return $null }
            Mock PublishSolution { return @{ 'Output' = 'NOT good'; 'ExitCode' = 1} }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 1
                $result.Message | Should Be 'Error installing the system components'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the system components. Return code: 1' }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error setting the system components version' {

            Mock GetSysComponentsCompiledVersion { return $null }
            Mock SetSysComponentsCompiledVersion { throw 'Error' }

            $result = Publish-OSPlatformSystemComponents -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunPublishSolution }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error setting the system components version'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error setting the system components version' }
            It 'Should not throw' { { Publish-OSPlatformSystemComponents -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When ServiceCenterUser is specified' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $result = Publish-OSPlatformSystemComponents -ServiceCenterUser 'Whatever' -ErrorVariable err -ErrorAction SilentlyContinue

            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
        }

        Context 'When credentials are specified' {

            Mock GetSysComponentsCompiledVersion { return $null }

            $cred = New-Object System.Management.Automation.PSCredential ("Whatever", $(ConvertTo-SecureString "admin" -AsPlainText -Force))

            $result = Publish-OSPlatformSystemComponents -Credential $cred -ErrorVariable err -ErrorAction SilentlyContinue

            $assRunPublishSolution = @{ 'CommandName' = 'PublishSolution'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $SCUser -eq "Whatever" -and $SCPass -eq "admin" } }

            It 'Should run the installation with other parameters' { Assert-MockCalled @assRunPublishSolution }
        }
    }
}
