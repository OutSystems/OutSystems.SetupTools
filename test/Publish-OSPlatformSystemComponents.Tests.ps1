Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSystemComponents Tests' {

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { Throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When platform is not installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Throw "Can find reg key" }
            Mock GetServerInstallDir { Throw "Error" }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "Outsystems platform is not installed"
            }

        }

        Context 'When service center is not installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Throw "Error" }

            It 'Should not run' {
                { Publish-OSPlatformSystemComponents } | Should Throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            }

        }

        Context 'When System Components is already installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }

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

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }
            Mock SetSysComponentsCompiledVersion {}

            It 'Should run and not throw any error' {

                { Publish-OSPlatformSystemComponents | Out-Null } | Should Not Throw

            }

        }

        Context 'When System Components is already installed and the force switch is specified' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }
            Mock SetSysComponentsCompiledVersion {}

            It 'Should not throw any errors' {

                { Publish-OSPlatformSystemComponents -Force | Out-Null } | Should Not Throw
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