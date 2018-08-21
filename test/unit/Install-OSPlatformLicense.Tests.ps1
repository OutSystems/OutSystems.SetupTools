Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSPlatformLicense Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetServerVersion { return '10.0.0.1' }
        Mock GetSCCompiledVersion { return '10.0.0.1' }
        Mock DownloadOSSources {}
        Mock RunConfigTool { return @{ 'Output' = 'All good'; 'ExitCode' = 0} }

        Context 'When user is not admin' {

            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSPlatformLicense } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }

        }

        Context 'When the platform server is not installed' {

            Mock GetServerVersion {
                return $null
            }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Outsystems platform is not installed"
            }

        }

        Context 'When service center and the platform dont have the same version' {

            Mock GetSCCompiledVersion { return '10.0.0.0' }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            }

        }

        Context 'When service center is not installed' {

            Mock GetSCCompiledVersion { return $null }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            }

        }

        Context 'When license path specified but the license file doesnt exist' {

            Mock Test-Path { return $false }

            It 'Should return an exception' {
                { Install-OSPlatformLicense -Path "c:\temp"} | Should throw "License file not found at c:\temp\license.lic"
            }

        }

        Context 'When theres an error downloading the trial license' {

            Mock DownloadOSSources { throw "Error downloading" }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Error downloading the license from the repository"
            }

        }

        Context 'When theres an error running the config tool' {

            Mock RunConfigTool { throw "Error executing the config tool" }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Error lauching the configuration tool"
            }

        }

        Context 'When the config tool returns an error' {

            Mock RunConfigTool { return @{ 'Output' = 'Not good'; 'ExitCode' = 1} }

            It 'Should return an exception' {
                { Install-OSPlatformLicense } | Should throw "Error uploading the license. Return code: 1"
            }

        }

        Context 'When everything is fine' {

            It 'Should run ok' {

                Install-OSPlatformLicense

                $assMParams = @{
                    'CommandName' = 'RunConfigTool'
                    'Times'       = 1
                    'Exactly'     = $true
                    'Scope'       = 'Context'
                }

                Assert-MockCalled @assMParams
            }

        }

    }
}
