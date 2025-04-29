Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSRepoAvailableVersions Tests' {

        $AzRepoFiles = (
            'DevelopmentEnvironment-11.14.3.56735.exe',
            'DevelopmentEnvironment-11.14.14.59923.exe',
            'DevelopmentEnvironment-11.14.16.60354.exe',
            'IntegrationStudio-11.14.22.112.exe',
            'IntegrationStudio-11.14.23.119.exe',
            'IntegrationStudio-11.14.24.121.exe',
            'LifeTimeWithPlatformServer-11.10.3.1469.0.exe',
            'LifeTimeWithPlatformServer-11.14.0.2131..exe',
            'LifeTimeWithPlatformServer-11.26.2.3750.exe',
            'PlatformServer-11.33.1.44835.exe',
            'PlatformServer-11.34.0.44828.exe',
            'PlatformServer-11.34.1.45035.exe',
            'SQLServer2017-SSEI-Expr.exe',
            'SSMS-Setup-ENU.exe',
            'ServiceStudio-11.55.16.64072.exe',
            'ServiceStudio-11.55.17.64089.exe',
            'ServiceStudio-11.55.18.64106.exe',
            'imagebuilder.exe',
            'license.lic',
            'license10.lic'
        )

        # Global mocks
        Mock GetAzStorageFileList { return $AzRepoFiles }

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