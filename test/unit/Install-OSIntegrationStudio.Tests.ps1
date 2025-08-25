Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSIntegrationStudio Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetIntegrationStudioVersion { return '11.14.17.61' }
        Mock GetIntegrationStudioInstallDir { return 'C:\Program Files\OutSystems\Integration Studio' }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When integration studio is installed with a lower version' {

            Mock GetIntegrationStudioVersion { return '11.14.17.61' }
            $result = Install-OSIntegrationStudio -Version '11.14.17.62' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems integration studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the integration studio is installed with a higher version' {

            Mock GetIntegrationStudioVersion { return '11.14.17.62' }
            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems integration studio already installed with an higher version 11.14.17.62'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems integration studio already installed with an higher version 11.14.17.62' }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When integration studio is already installed with the right version' {

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems integration studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }

        }


        Context 'When theres an error downloading the sources from the repo' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock DownloadOSSources { throw "Error" }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading the installer from repository. Check if version is correct'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading the installer from repository. Check if version is correct' }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When the integration studio is not installed and installs successfully' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems\Integration Studio" } }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems integration studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the integration studio is not installed and -FullPathInstallDir is specified' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems" } }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -InstallDir 'C:\Program Files\Outsystems' -FullPathInstallDir -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems integration studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When integration studio installer returns an error' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 10} }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing the Outsystems integration studio'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the Outsystems integration studio. Exit code: 10' }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform installer asks for reboot' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 3011} }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems integration studio successfully installed but a reboot is needed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the integration studio installer throws an exception' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { throw "Big error" }

            $result = Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error starting the installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the installation' }
            It 'Should not throw' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the caller changes the ErrorAction to stop' {

            Mock IsAdmin { return $false }
            It 'Should throw an exception' { { Install-OSIntegrationStudio -Version '11.14.17.61' -ErrorAction Stop } | Should throw }
        }

        Context 'When asked to install an unsupported version' {

            Mock GetIntegrationStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }

            It 'Should return the right result' {
                $result.Success = $false
                $result.ExitCode = -1
                $result.Message = 'Unsupported version'
            }

            It 'Should output an error' { $err[-1] | Should Be 'Unsupported version' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
