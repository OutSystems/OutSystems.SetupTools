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

            Mock IsAdmin { return $false }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

#            It 'Should not run the installation' { Assert-MockCalled @assNotRunParams }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSServer -Version '10.0.0.1' -ErrorAction SilentlyContinue } | Should Not throw }
        }

    }
}
