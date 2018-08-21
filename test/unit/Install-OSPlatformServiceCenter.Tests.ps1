Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSPlatformServiceCenter Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock RunSCInstaller { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }
        Mock SetSCCompiledVersion {}

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSPlatformServiceCenter } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            It 'Should return an exception' {
                { Install-OSPlatformServiceCenter } | Should throw "Outsystems platform is not installed"
            }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }

            It 'Should return an exception' {
                { Install-OSPlatformServiceCenter } | Should throw "Outsystems platform is not installed"
            }

        }

        Context 'When service center and the platform dont have the same version' {

            Mock GetSCCompiledVersion { return '10.0.0.0' }

            It 'Should run the installation' {

                Install-OSPlatformServiceCenter

                $assMParams = @{
                                'CommandName' = 'RunSCInstaller'
                                'Times'       = 1
                                'Exactly'     = $true
                                'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When service center is not installed' {

            Mock GetSCCompiledVersion { return $null }

            It 'Should run the installation' {

                Install-OSPlatformServiceCenter

                $assMParams = @{
                                'CommandName' = 'RunSCInstaller'
                                'Times'       = 1
                                'Exactly'     = $true
                                'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When service center and platform have the same version' {

            It 'Should not run the installation' {

                Install-OSPlatformServiceCenter

                $assMParams = @{
                                'CommandName' = 'RunSCInstaller'
                                'Times'       = 0
                                'Exactly'     = $true
                                'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When service center and platform have the same version but the force switch is specified' {

            It 'Should run the installation' {

                Install-OSPlatformServiceCenter -Force

                $assMParams = @{
                                'CommandName' = 'RunSCInstaller'
                                'Times'       = 1
                                'Exactly'     = $true
                                'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When theres an error launching the scinstaller' {

            Mock GetSCCompiledVersion { return $null }
            Mock RunSCInstaller { throw "Error lauching the scinstaller" }

            It 'Should return an exception' {
                { Install-OSPlatformServiceCenter } | Should throw "Error lauching the service center installer"
            }

        }

        Context 'When theres an error installing service center' {

            Mock GetSCCompiledVersion { return $null }
            Mock RunSCInstaller { return @{ 'Output' = 'NOT good'; 'ExitCode' = 1} }

            It 'Should return an exception' {
                { Install-OSPlatformServiceCenter } | Should throw "Error installing service center. Return code: 1"
            }

        }

    }
}
