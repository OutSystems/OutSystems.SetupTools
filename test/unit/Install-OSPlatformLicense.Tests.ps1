Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSPlatformLicense Tests' {

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock DownloadOSSources {}
        Mock RunConfigTool { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        Context 'When user is not admin' {

            Mock IsAdmin { return $frue }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion { return $null }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center and the platform dont have the same version' {

            Mock GetSCCompiledVersion { return '10.0.0.0' }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When service center is not installed' {

            Mock GetSCCompiledVersion { return $null }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }

        }

        Context 'When license path specified but the license file doesnt exist' {

            Mock Test-Path { return $false }

            Install-OSPlatformLicense -Path "c:\temp" -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'License file not found at c:\temp\license.lic' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error downloading the trial license' {

            Mock DownloadOSSources { throw "Error downloading" }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error downloading the license from the repository' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When theres an error starting the config tool' {

            Mock RunConfigTool { throw "Error executing the config tool" }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error lauching the configuration tool' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the config tool returns an error' {

            Mock RunConfigTool { return @{ 'Output' = 'Not good'; 'ExitCode' = 1} }

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error uploading the license. Return code: 1' }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When everything is fine' {

            Install-OSPlatformLicense -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should run ok' {
                $assMParams = @{
                    'CommandName' = 'RunConfigTool'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }
                Assert-MockCalled @assMParams
            }

            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSPlatformLicense -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
