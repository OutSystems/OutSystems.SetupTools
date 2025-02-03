Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSRepoAvailableVersions Tests' {

        Context 'When getting Platform Server versions' {

            $result = Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Service Studio versions' {

            $result = Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Integration Studio versions' {

            $result = Get-OSRepoAvailableVersions -Application 'IntegrationStudio' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Lifetime versions' {

            $result = Get-OSRepoAvailableVersions -Application 'Lifetime' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

    }
}
