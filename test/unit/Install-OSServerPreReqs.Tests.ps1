Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServerPreReqs Tests' {

        # Global mocks
        Mock CheckRunAsAdmin {}
        Mock GetDotNet4Version { return 394254 }
        Mock DownloadOSSources {}
        Mock Start-Process { return @{ 'Output' = 'All good'; 'ExitCode' = 0 } }
        Mock InstallWindowsFeatures {}
        Mock ConfigureServiceWMI {}
        Mock ConfigureServiceWindowsSearch {}
        Mock DisableFIPS {}
        Mock ConfigureWindowsEventLog {}
        Mock ConfigureMSMQDomainServer {}

        Context 'When user is not admin' {
            Mock CheckRunAsAdmin { throw "The current user is not Administrator or not running this script in an elevated session" }

            It 'Should not run' {
                { Install-OSServerPreReqs -MajorVersion '10.0' } | Should throw "The current user is not Administrator or not running this script in an elevated session"
            }
        }

    }
}
