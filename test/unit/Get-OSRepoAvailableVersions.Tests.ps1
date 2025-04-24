Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSRepoAvailableVersions Tests' {

        Context 'When getting Platform Server versions' {

            $result = Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Platform Server latest version' {

            $result = Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '11' -Latest -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return exactly one version' { $result.Count | Should Be 1 }
        }

        Context 'When getting Development Environment versions' {

            $result = Get-OSRepoAvailableVersions -Application 'DevelopmentEnvironment' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Development Environment latest version' {

            $result = Get-OSRepoAvailableVersions -Application 'DevelopmentEnvironment' -MajorVersion '11' -Latest -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return exactly one version' { $result.Count | Should Be 1 }
        }

        Context 'When getting Lifetime versions' {

            $result = Get-OSRepoAvailableVersions -Application 'Lifetime' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Lifetime latest version' {

            $result = Get-OSRepoAvailableVersions -Application 'Lifetime' -MajorVersion '11' -Latest -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return exactly one version' { $result.Count | Should Be 1 }
        }

        Context 'When getting Integration Studio versions' {

            $result = Get-OSRepoAvailableVersions -Application 'IntegrationStudio' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Integration Studio latest version' {

            $result = Get-OSRepoAvailableVersions -Application 'IntegrationStudio' -MajorVersion '11' -Latest -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return exactly one version' { $result.Count | Should Be 1 }
        }

        Context 'When getting Service Studio versions' {

            $result = Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return at least one version' { $result.Count | Should BeGreaterThan 0 }
        }

        Context 'When getting Service Studio latest version' {

            $result = Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11' -Latest -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not have errors' { $err.Count | Should Be 0 }
            It 'Should return exactly one version' { $result.Count | Should Be 1 }
        }

    }
}