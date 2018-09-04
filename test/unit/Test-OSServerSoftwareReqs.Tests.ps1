Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Test-OSServerSoftwareReqs Tests' {

        # Global mocks
        Mock GetOperatingSystemProductType { return 2 }
        Mock GetOperatingSystemVersion { return "10.0.14393" }

        $assRunGetOperatingSystemProductType = @{ 'CommandName' = 'GetOperatingSystemProductType'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assRunGetOperatingSystemVersion = @{ 'CommandName' = 'GetOperatingSystemVersion'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }
        $assNotRunGetOperatingSystemVersion = @{ 'CommandName' = 'GetOperatingSystemVersion'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When the machine is not a server type' {

            Mock GetOperatingSystemProductType { return 1 }

            $result = Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetOperatingSystemProductType' { Assert-MockCalled @assRunGetOperatingSystemProductType }
            It 'Should not call GetOperatingSystemVersion' { Assert-MockCalled @assNotRunGetOperatingSystemVersion }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'Operating system not supported. Only server editions are supported'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Operating system not supported. Only server editions are supported' }
            It 'Should not throw' { { Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install OS10 in an OS less than win2k12' {

            Mock GetOperatingSystemVersion { return "5.0.0.0" }

            $result = Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetOperatingSystemProductType' { Assert-MockCalled @assRunGetOperatingSystemProductType }
            It 'Should call GetOperatingSystemVersion' { Assert-MockCalled @assRunGetOperatingSystemVersion }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'This operating system version is not supported for Outsystems 10.0'
            }
            It 'Should output an error' { $err[-1] | Should Be 'This operating system version is not supported for Outsystems 10.0' }
            It 'Should not throw' { { Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install OS11 in an OS less than win2k16' {

            Mock GetOperatingSystemVersion { return "6.1.0.0" }

            $result = Test-OSServerSoftwareReqs -MajorVersion 11.0 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetOperatingSystemProductType' { Assert-MockCalled @assRunGetOperatingSystemProductType }
            It 'Should call GetOperatingSystemVersion' { Assert-MockCalled @assRunGetOperatingSystemVersion }
            It 'Should return the right result' {
                $result.Result | Should Be $false
                $result.Message | Should Be 'This operating system version is not supported for Outsystems 11.0'
            }
            It 'Should output an error' { $err[-1] | Should Be 'This operating system version is not supported for Outsystems 11.0' }
            It 'Should not throw' { { Test-OSServerSoftwareReqs -MajorVersion 11.0 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install OS10 on win2k16' {

            $result = Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetOperatingSystemProductType' { Assert-MockCalled @assRunGetOperatingSystemProductType }
            It 'Should call GetOperatingSystemVersion' { Assert-MockCalled @assRunGetOperatingSystemVersion }
            It 'Should return the right result' {
                $result.Result | Should Be $true
                $result.Message | Should Be 'Operating system was validated for Outsystems'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When trying to install OS11 on win2k16' {

            $result = Test-OSServerSoftwareReqs -MajorVersion 10.0 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should call GetOperatingSystemProductType' { Assert-MockCalled @assRunGetOperatingSystemProductType }
            It 'Should call GetOperatingSystemVersion' { Assert-MockCalled @assRunGetOperatingSystemVersion }
            It 'Should return the right result' {
                $result.Result | Should Be $true
                $result.Message | Should Be 'Operating system was validated for Outsystems'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Test-OSServerSoftwareReqs -MajorVersion 11.0 -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
