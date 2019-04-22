Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServiceStudio Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServiceStudioVersion { return '10.0.0.1' }
        Mock GetServiceStudioInstallDir { return 'C:\Program Files\OutSystems\Development Environment 10.0' }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is installed with a lower version' {

            Mock GetServiceStudioVersion { return '10.0.0.0' }
            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service studio is installed with a higher version' {

            Mock GetServiceStudioVersion { return '10.0.0.2' }
            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems service studio already installed with an higher version 10.0.0.2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems service studio already installed with an higher version 10.0.0.2' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio is already installed with the right version' {

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When theres an error downloading the sources from the repo' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock DownloadOSSources { throw "Error" }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading the installer from repository. Check if version is correct'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading the installer from repository. Check if version is correct' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When the service studio is not installed and installs successfully' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems\Development Environment 10.0" } }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service studio is not installed and -FullPathInstallDir is specified' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems" } }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -InstallDir 'C:\Program Files\Outsystems' -FullPathInstallDir -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems service studio successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service studio installer returns an error' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 10} }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing the Outsystems service studio'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the Outsystems service studio. Exit code: 10' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform installer asks for reboot' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 3011} }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems service studio successfully installed but a reboot is needed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the service studio installer throws an exception' {

            Mock GetServiceStudioVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { throw "Big error" }

            $result = Install-OSServiceStudio -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error starting the service center installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the service center installation' }
            It 'Should not throw' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the caller changes the ErrorAction to stop' {

            Mock IsAdmin { return $false }
            It 'Should throw an exception' { { Install-OSServiceStudio -Version '10.0.0.1' -ErrorAction Stop } | Should throw }
        }

    }
}
