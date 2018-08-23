Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServiceStudio Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetServiceStudioVersion { return '10.0.0.1' }
        Mock GetServiceStudioInstallDir { return 'C:\Program Files\OutSystems\Development Environment 10.0' }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSServiceStudio -Version '10.0.0.1' } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When service studio is not installed' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServiceStudioInstallDir { return $null }

            It 'Should run the installation' {

                Install-OSServiceStudio -Version '10.0.0.1'

                $assMParams = @{
                    'CommandName' = 'Start-Process'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When service studio is installed with a lower version' {

            Mock GetServiceStudioVersion { return '10.0.0.0' }

            It 'Should run the installation' {

                Install-OSServiceStudio -Version '10.0.0.1'

                $assMParams = @{
                    'CommandName' = 'Start-Process'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

        Context 'When service studio is installed with a higher version' {

            Mock GetServiceStudioVersion { return '10.0.0.2' }

            It 'Should return an exception' {
               { Install-OSServiceStudio -Version '10.0.0.1' } | Should throw "Outsystems service studio already installed with an higher version 10.0.0.2"
            }

        }

        Context 'When the platform server is already installed with the right version' {

            It 'Should not run the installation' {

                Install-OSServiceStudio -Version '10.0.0.1'

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

            Mock GetServiceStudioVersion { return $null }
            Mock GetServiceStudioInstallDir { return $null }
            Mock DownloadOSSources { throw "Error" }

            It 'Should return an exception' {
               { Install-OSServiceStudio -Version '10.0.0.1' } | Should throw "Error downloading the installer from repository. Check if version is correct"
            }

        }

        Context 'When local source is specified but the file doesnt exists' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServiceStudioInstallDir { return $null }
            Mock Test-Path { return $false }

            It 'Should return an exception' {
               { Install-OSServiceStudio -Version '10.0.0.1' -SourcePath 'c:\whatever'} | Should throw "Cant file the setup file at c:\whatever\DevelopmentEnvironment-10.0.0.1.exe"
            }

        }

    }
}
