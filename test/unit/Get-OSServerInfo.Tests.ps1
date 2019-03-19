Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerInfo Tests' {

        # private.key file
        $filecontent = '--WARNING: this file contains your private encryption key. This key is your personal#'
        $filecontent += '--confidential information and must not be shared with anyone. Under no circumstances#'
        $filecontent += '--should you give access to your encryption key to other people. No OutSystems employee#'
        $filecontent += '--will ever ask you to provide this encryption key. This key is not and will never be necessary#'
        $filecontent += '--to carry a successful interaction with OutSystems employees (e.g. support scenarios).#'
        $filecontent += 'v4iwANAsGDRpjiEpO8Kt3Q=='
        $filecontent = $filecontent.Split('#')

        # Global mocks
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetServerVersion { return '11.0.0.0' }
        Mock GetServerMachineName { return 'MYMACHINE' }
        Mock GetServerSerialNumber { return 'XBI-NMO-IL5-OYI-9SO-LCU-4SQ-QUT' }
        Mock Test-Path { return $true }
        Mock Get-Content { return $filecontent }

        $assGetServerInstallDir = @{ 'CommandName' = 'GetServerInstallDir'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerVersion = @{ 'CommandName' = 'GetServerVersion'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerMachineName = @{ 'CommandName' = 'GetServerMachineName'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assGetServerSerialNumber = @{ 'CommandName' = 'GetServerSerialNumber'; 'Times' = 1; 'Exactly' = $true ; 'Scope' = 'Context' }

        $assNotGetServerInstallDir = @{ 'CommandName' = 'GetServerInstallDir'; 'Times' = 0; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assNotGetServerVersion = @{ 'CommandName' = 'GetServerVersion'; 'Times' = 0; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assNotGetServerMachineName = @{ 'CommandName' = 'GetServerMachineName'; 'Times' = 0; 'Exactly' = $true ; 'Scope' = 'Context' }
        $assNotGetServerSerialNumber = @{ 'CommandName' = 'GetServerSerialNumber'; 'Times' = 0; 'Exactly' = $true ; 'Scope' = 'Context' }

        Context 'When platform is not installed' {

            Mock GetServerInstallDir { return $null }

            Get-OSServerInfo -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should call the GetServerInstallDir' { Assert-MockCalled @assGetServerInstallDir }
            It 'Should call the GetServerVersion' { Assert-MockCalled @assGetServerVersion }
            It 'Should not call the GetServerMachineName' { Assert-MockCalled @assNotGetServerMachineName }
            It 'Should not call the GetServerSerialNumber' { Assert-MockCalled @assNotGetServerSerialNumber }
            It 'Should output an error' { $err[-1] | Should Be 'Outsystems platform is not installed' }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed and configured' {

            $output = Get-OSServerInfo -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should return the correct install directory' { $output.InstallDir | Should Be 'C:\Program Files\OutSystems\Platform Server' }
            It 'Should return the correct server version' { $output.Version| Should Be '11.0.0.0' }
            It 'Should return the correct machine name' { $output.MachineName | Should Be 'MYMACHINE' }
            It 'Should return the correct serial number' { $output.SerialNumber | Should Be 'XBI-NMO-IL5-OYI-9SO-LCU-4SQ-QUT' }
            It 'Should return the correct private key' { $output.PrivateKey | Should Be 'v4iwANAsGDRpjiEpO8Kt3Q==' }
            It 'Should output a version type property' { ($output.Version).GetType().Name | Should Be 'Version' }
            It 'Should call the GetServerInstallDir' { Assert-MockCalled @assGetServerInstallDir }
            It 'Should call the GetServerVersion' { Assert-MockCalled @assGetServerVersion }
            It 'Should call the GetServerMachineName' { Assert-MockCalled @assGetServerMachineName }
            It 'Should call the GetServerSerialNumber' { Assert-MockCalled @assGetServerSerialNumber }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the platform server is installed but NOT configured' {

            Mock GetServerMachineName { return $null }
            Mock GetServerSerialNumber { return $null }
            Mock Test-Path { return $false }

            $output = Get-OSServerInfo -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should return the correct install directory' { $output.InstallDir | Should Be 'C:\Program Files\OutSystems\Platform Server' }
            It 'Should return the correct server version' { $output.Version| Should Be '11.0.0.0' }
            It 'Should return an empty machine name' { $output.MachineName | Should Be $null }
            It 'Should return an empty serial number' { $output.SerialNumber | Should Be $null }
            It 'Should return an empty private key' { $output.PrivateKey | Should Be '' }
            It 'Should output a version type property' { ($output.Version).GetType().Name | Should Be 'Version' }
            It 'Should call the GetServerInstallDir' { Assert-MockCalled @assGetServerInstallDir }
            It 'Should call the GetServerVersion' { Assert-MockCalled @assGetServerVersion }
            It 'Should call the GetServerMachineName' { Assert-MockCalled @assGetServerMachineName }
            It 'Should call the GetServerSerialNumber' { Assert-MockCalled @assGetServerSerialNumber }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When private.key has an issue' {

            Mock Test-Path { return $true }
            Mock Get-Content { return '-- whatever content' }

            $output = Get-OSServerInfo -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should return an empty private key' { $output.PrivateKey | Should Be '' }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSServerInfo -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
