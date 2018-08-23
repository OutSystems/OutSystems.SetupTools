Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServer Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSServer -Version '10.0.0.1' } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            It 'Should run the installation' {

                Install-OSServer -Version '10.0.0.1'

                $assMParams = @{
                    'CommandName' = 'Start-Process'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When the platform server is installed with a lower version' {

            Mock GetServerVersion { return '10.0.0.0' }

            It 'Should run the installation' {

                Install-OSServer -Version '10.0.0.1'

                $assMParams = @{
                    'CommandName' = 'Start-Process'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When the platform server is installed with a higher version' {

            Mock GetServerVersion { return '10.0.0.2' }

            It 'Should return an exception' {
               { Install-OSServer -Version '10.0.0.1' } | Should throw "Outsystems platform server already installed with an higher version 10.0.0.2"
            }

        }

        Context 'When the platform server is already installed with the right version' {

            It 'Should not run the installation' {

                Install-OSServer -Version '10.0.0.1'

                $assMParams = @{
                    'CommandName' = 'Start-Process'
                    'Times'       = 0
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When theres an error downloading the sources from the repo' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock DownloadOSSources { throw "Error" }

            It 'Should return an exception' {
               { Install-OSServer -Version '10.0.0.1' } | Should throw "Error downloading the installer from repository. Check if version is correct"
            }

        }

        Context 'When local source is specified but the file doesnt exists' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Test-Path { return $false }

            It 'Should return an exception' {
               { Install-OSServer -Version '10.0.0.1' -SourcePath 'c:\whatever'} | Should throw "Cant find the setup file at c:\whatever\PlatformServer-10.0.0.1.exe"
            }

        }

    }
}
