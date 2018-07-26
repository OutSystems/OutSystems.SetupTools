Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module .\..\src\Outsystems.SetupTools

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformLifetime Tests' {

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { Throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSPlatformLifetime } | Should Throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When platform is not installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Throw "Can find reg key" }
            Mock GetServerInstallDir { Throw "Error" }

            It 'Should not run' {
                { Install-OSPlatformLifetime } | Should Throw "Outsystems platform is not installed"
            }

        }

        Context 'When service center is not installed or has a wrong version' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Throw "Error" }

            It 'Should not run' {
                { Install-OSPlatformLifetime } | Should Throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            }

        }

        Context 'When systems components is not installed or has a wrong version' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Throw "Error" }

            It 'Should not run' {
                { Install-OSPlatformLifetime } | Should Throw "Systems components version mismatch. You should run the Publish-OSPlatformSystemComponents first"
            }

        }

        Context 'When lifetime is already installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock GetLifetimeCompiledVersion { Return "10.0.0.1" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }

            It 'Should skip the installation' {

                Install-OSPlatformLifetime

                $assMParams = @{
                    'CommandName' = 'PublishSolution'
                    'Times' = 0
                    'Exactly' = $true
                    'Scope' = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When lifetime needs to be installed' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock GetLifetimeCompiledVersion { Throw "Error" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }
            Mock SetLifetimeCompiledVersion {}

            It 'Should run and not throw any error' {

                { Install-OSPlatformLifetime | Out-Null } | Should Not Throw

            }

        }

        Context 'When lifetime is already installed and the force switch is specified' {

            Mock CheckRunAsAdmin { Return "OK" }
            Mock GetServerVersion { Return "10.0.0.1" }
            Mock GetServerInstallDir { Return "C:\Program Files\OutSystems\" }
            Mock GetSCCompiledVersion { Return "10.0.0.1" }
            Mock GetSysComponentsCompiledVersion { Return "10.0.0.1" }
            Mock GetLifetimeCompiledVersion { Return "10.0.0.1" }
            Mock PublishSolution {
                Return @{
                    'Output' = 'Evertyhing installed'
                    'ExitCode' = 0
                }
            }
            Mock SetLifetimeCompiledVersion {}

            It 'Should not throw any errors' {

                { Install-OSPlatformLifetime -Force | Out-Null } | Should Not Throw
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