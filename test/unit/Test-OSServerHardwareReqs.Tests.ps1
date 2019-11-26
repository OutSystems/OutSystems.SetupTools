Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Test-OSServerHardwareReqs Tests' {

        # Global mocks
        Mock GetNumberOfCores { return 4 }
        Mock GetInstalledRAM { return 8 }

        $assRunGetNumberOfCores = @{ 'CommandName' = 'GetNumberOfCores'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assRunGetInstalledRAM = @{ 'CommandName' = 'GetInstalledRAM'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunGetInstalledRAM = @{ 'CommandName' = 'GetInstalledRAM'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'OS10. When the machine does not have the required num of cores' {

            Mock GetNumberOfCores { return 1 }

            $result = Test-OSServerHardwareReqs -MajorVersion 10 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should not call GetInstalledRAM' { Assert-MockCalled @assNotRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'Hardware not supported for Outsystems 10. Number of CPU cores is less than 2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Hardware not supported for Outsystems 10. Number of CPU cores is less than 2' }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 10 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'OS10. When the machine does not have enought mem' {

            Mock GetInstalledRAM { return 1 }

            $result = Test-OSServerHardwareReqs -MajorVersion 10 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should call GetInstalledRAM' { Assert-MockCalled @assRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'Hardware not supported for Outsystems 10. Server has less than 4 GB'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Hardware not supported for Outsystems 10. Server has less than 4 GB' }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 10 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'OS10. When the machine is OK' {

            $result = Test-OSServerHardwareReqs -MajorVersion 10 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should call GetInstalledRAM' { Assert-MockCalled @assRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $true
                $result.Message | Should Be 'Hardware was validated for Outsystems 10'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 10 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'OS11. When the machine does not have the required num of cores' {

            Mock GetNumberOfCores { return 1 }

            $result = Test-OSServerHardwareReqs -MajorVersion 11 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should not call GetInstalledRAM' { Assert-MockCalled @assNotRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'Hardware not supported for Outsystems 11. Number of CPU cores is less than 2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Hardware not supported for Outsystems 11. Number of CPU cores is less than 2' }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 11 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'OS11. When the machine does not have enought mem' {

            Mock GetInstalledRAM { return 1 }

            $result = Test-OSServerHardwareReqs -MajorVersion 11 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should call GetInstalledRAM' { Assert-MockCalled @assRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'Hardware not supported for Outsystems 11. Server has less than 4 GB'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Hardware not supported for Outsystems 11. Server has less than 4 GB' }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 11 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'OS11. When the machine is OK' {

            $result = Test-OSServerHardwareReqs -MajorVersion 11 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetNumberOfCores' { Assert-MockCalled @assRunGetNumberOfCores }
            It 'Should call GetInstalledRAM' { Assert-MockCalled @assRunGetInstalledRAM }
            It 'Should return the right result' {
                $result.Result | Should Be $true
                $result.Message | Should Be 'Hardware was validated for Outsystems 11'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Test-OSServerHardwareReqs -MajorVersion 11 -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
