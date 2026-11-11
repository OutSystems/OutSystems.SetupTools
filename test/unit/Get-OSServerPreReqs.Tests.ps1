Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSServerPreReqs .NET Hosting Bundle requirements Tests' {
        # Global mocks
        Mock IsAdmin { return $true }
        Mock SendFunctionStartEvent {}
        Mock LogMessage {}
        Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = $Null; 'RebootNeeded' = $False } }
        Mock GetDotNet4Version { return $null }
        Mock GetDotNetHostingBundleVersions { return '0.0.0.0' }

        # Requirement titles are logged by Get-OSServerPreReqs as "<Title>: [OK|NOT OK]"
        $assRequired6 = @{ 'CommandName' = 'LogMessage'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 6.0 Windows Server Hosting: *' } }
        $assNotRequired6 = @{ 'CommandName' = 'LogMessage'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 6.0 Windows Server Hosting: *' } }
        $assRequired8 = @{ 'CommandName' = 'LogMessage'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 8.0 Windows Server Hosting: *' } }
        $assNotRequired8 = @{ 'CommandName' = 'LogMessage'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 8.0 Windows Server Hosting: *' } }
        $assRequired8Or11 = @{ 'CommandName' = 'LogMessage'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 8.0 or 11.0 Windows Server Hosting: *' } }
        $assNotRequired8Or11 = @{ 'CommandName' = 'LogMessage'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 8.0 or 11.0 Windows Server Hosting: *' } }
        $assRequired11 = @{ 'CommandName' = 'LogMessage'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 11.0 Windows Server Hosting: *' } }
        $assNotRequired11 = @{ 'CommandName' = 'LogMessage'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like '.NET 11.0 Windows Server Hosting: *' } }
        # Sentinel: proves the requirement list was built, so the "not required" assertions are meaningful
        $assRequirementsEvaluated = @{ 'CommandName' = 'LogMessage'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Message -like 'Windows Features: *' } }

        Context 'When the minor version is not specified' {

            $result = Get-OSServerPreReqs -MajorVersion '11'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 6.0 Hosting Bundle' { Assert-MockCalled @assRequired6 }
            It 'Should require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assRequired8 }
            It 'Should require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assRequired11 }
            It 'Should not require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assNotRequired8Or11 }
            It 'Should not throw' { { Get-OSServerPreReqs -MajorVersion '11' } | Should Not throw }
        }

        Context 'When the version is 11.23.0 (lower bound, minor version specified)' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '23' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 6.0 Hosting Bundle' { Assert-MockCalled @assRequired6 }
            It 'Should not require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assNotRequired8 }
            It 'Should not require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assNotRequired11 }
            It 'Should not require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assNotRequired8Or11 }
        }

        Context 'When the version is 11.26.0 (minor version specified, below 11.27)' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '26' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 6.0 Hosting Bundle' { Assert-MockCalled @assRequired6 }
            It 'Should not require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assNotRequired8 }
            It 'Should not require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assNotRequired11 }
            It 'Should not require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assNotRequired8Or11 }
        }

        Context 'When the version is 11.27.0' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '27' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assRequired8 }
            It 'Should not require .NET 6.0 Hosting Bundle' { Assert-MockCalled @assNotRequired6 }
            It 'Should not require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assNotRequired11 }
        }

        Context 'When the version is 11.41.0 (just below 11.42)' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '41' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assRequired8 }
            It 'Should not require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assNotRequired11 }
            It 'Should not require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assNotRequired8Or11 }
        }

        Context 'When the version is 11.42.0' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '42' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assRequired8Or11 }
            It 'Should not require .NET 8.0 Hosting Bundle on its own' { Assert-MockCalled @assNotRequired8 }
            It 'Should not require .NET 11.0 Hosting Bundle on its own' { Assert-MockCalled @assNotRequired11 }
        }

        Context 'When the version is 11.46.0' {

            $result = Get-OSServerPreReqs -MajorVersion '11' -MinorVersion '46' -PatchVersion '0'

            It 'Should evaluate the requirements' { Assert-MockCalled @assRequirementsEvaluated }
            It 'Should require .NET 11.0 Hosting Bundle' { Assert-MockCalled @assRequired11 }
            It 'Should not require .NET 6.0 Hosting Bundle' { Assert-MockCalled @assNotRequired6 }
            It 'Should not require .NET 8.0 Hosting Bundle' { Assert-MockCalled @assNotRequired8 }
            It 'Should not require the combined .NET 8.0 or 11.0 requirement' { Assert-MockCalled @assNotRequired8Or11 }
        }
    }
}
