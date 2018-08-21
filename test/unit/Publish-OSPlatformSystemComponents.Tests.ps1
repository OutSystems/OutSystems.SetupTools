Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSystemComponents Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock GetSysComponentsCompiledVersion { return '10.0.0.1' }
        Mock PublishSolution { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock SetSysComponentsCompiledVersion {}

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { Throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When platform is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "Outsystems platform is not installed"
            }

        }

        Context 'When service center is not installed' {

            Mock GetSCCompiledVersion { return $null }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            }

        }

        Context 'When System Components is already installed' {

            It 'Should skip the installation' {

                Publish-OSPlatformSystemComponents

                $assMParams = @{
                    'CommandName' = 'PublishSolution'
                    'Times' = 0
                    'Exactly' = $true
                    'Scope' = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When System Components needs to be installed' {

            Mock GetSysComponentsCompiledVersion { return $null }

            It 'Should run and not throw any error' {

                { Publish-OSPlatformSystemComponents } | Should Not Throw

            }

            It 'Should run the installation' {

                $assMParams = @{
                    'CommandName' = 'PublishSolution'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When System Components is already installed and the force switch is specified' {

            It 'Should not throw any errors' {

                { Publish-OSPlatformSystemComponents -Force } | Should Not throw
            }

            It 'Should run the installation' {

                $assMParams = @{
                    'CommandName' = 'PublishSolution'
                    'Times' = 1
                    'Exactly' = $true
                    'Scope' = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

    }
}
