Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerInfo Tests' {

        # Global mocks
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetServerVersion { return '11.0.0.0' }
        Mock GetServerMachineName { return 'MYMACHINE' }
        Mock GetServerSerialNumber { return 'XBI-NMO-IL5-OYI-9SO-LCU-4SQ-QUT' }

        $assGetServerInstallDir = @{ 'CommandName' = 'GetServerInstallDir'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerVersion = @{ 'CommandName' = 'GetServerVersion'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerMachineName = @{ 'CommandName' = 'GetServerMachineName'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerSerialNumber = @{ 'CommandName' = 'GetServerSerialNumber'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }

        Context 'When platform is not installed' {

            Mock GetServerInstallDir { return $null }

            Get-OSServerInfo -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should call the GetServerInstallDir' { Assert-MockCalled @assGetServerInstallDir }
            It 'Should call the GetServerVersion' { Assert-MockCalled @assGetServerVersion }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed' {

            $output = Get-OSServerInfo

            It 'Should return the correct install directory' { $output.InstallDir | Should Be 'C:\Program Files\OutSystems\Platform Server' }
            It 'Should return the correct server version' { $output.Version| Should Be '11.0.0.0' }
            It 'Should return the correct machine name' { $output.MachineName | Should Be 'MYMACHINE' }
            It 'Should return the correct serial number' { $output.SerialNumber | Should Be 'XBI-NMO-IL5-OYI-9SO-LCU-4SQ-QUT' }
            It 'Should output a version type property' { ($output.Version).GetType().Name | Should Be 'Version' }
            It 'Should call the GetServerInstallDir' { Assert-MockCalled @assGetServerInstallDir }
            It 'Should call the GetServerVersion' { Assert-MockCalled @assGetServerVersion }
            It 'Should call the GetServerMachineName' { Assert-MockCalled @assGetServerMachineName }
            It 'Should call the GetServerSerialNumber' { Assert-MockCalled @assGetServerSerialNumber }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
