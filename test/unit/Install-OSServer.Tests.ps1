Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServer Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed with a lower version' {

            Mock GetServerVersion { return '10.0.0.0' }
            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed with a higher version' {

            Mock GetServerVersion { return '10.0.0.2' }
            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Outsystems platform server already installed with an higher version 10.0.0.2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform server already installed with an higher version 10.0.0.2' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is already installed with the right version' {

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When theres an error downloading the sources from the repo' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock DownloadOSSources { throw "Error" }

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading the installer from repository. Check if version is correct'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading the installer from repository. Check if version is correct' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When the platform server is not installed and installs successfully' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is not installed and -FullPathInstallDir is specified' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems " } }

            $result = Install-OSServer -Version '10.0.0.1' -InstallDir 'C:\Program Files\Outsystems' -FullPathInstallDir -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is not installed and -AdditionalParameters is specified' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $ArgumentList -eq "/S /D=C:\Program Files\Outsystems TestParam" } }

            $result = Install-OSServer -Version '10.0.0.1' -InstallDir 'C:\Program Files\Outsystems' -AdditionalParameters "TestParam" -FullPathInstallDir -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform installer returns an error' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 10} }

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing the Outsystems platform server'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing the Outsystems platform server. Exit code: 10' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform installer asks for reboot' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { return @{ 'Output' = 'Not good'; 'ExitCode' = 3011} }

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server successfully installed but a reboot is needed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform installer throws an exception' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }
            Mock Start-Process { throw "Big error" }

            $result = Install-OSServer -Version '10.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation' { Assert-MockCalled @assRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error starting the plaform server installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the plaform server installation' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the caller changes the ErrorAction to stop' {

            Mock IsAdmin { return $false }
            It 'Should throw an exception' { { Install-OSServer -Version '10.0.0.1' -ErrorAction Stop } | Should throw }
        }

        Context 'When lifetime switch is specified' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $FilePath -eq "$ENV:TEMP\LifeTimeWithPlatformServer-11.0.0.1.exe" } }

            $result = Install-OSServer -Version '11.0.0.1' -WithLifeTime -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation using the lifetime installer' { Assert-MockCalled @assRunParams }
        }

        Context 'When lifetime switch is NOT specified' {

            Mock GetServerVersion { return $null }
            Mock GetServerInstallDir { return $null }

            $assRunParams = @{ 'CommandName' = 'Start-Process'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $FilePath -eq "$ENV:TEMP\PlatformServer-11.0.0.1.exe" } }

            $result = Install-OSServer -Version '11.0.0.1' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the installation using the normal installer' { Assert-MockCalled @assRunParams }
        }
    }
}
