Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

# Stand-in for the .NET Core Uninstall Tool executable so it can be mocked on machines where it is not installed.
# It is removed at the end of the file, so later test files in the same session reach the real tool.
$stubExisted = Test-Path -Path 'function:\dotnet-core-uninstall'
function global:dotnet-core-uninstall
{
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline = $true)]$InputObject,
        [Parameter(ValueFromRemainingArguments = $true)]$Arguments
    )
}

try
{
    InModuleScope -ModuleName OutSystems.SetupTools {
        Describe 'UninstallPreviousDotNetCorePackages Tests' {

            Mock LogMessage {}
            Mock Get-ChildItem { return 'key' } -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' }

            # The registry entries the function reads. The tool mock removes the entries of the version it is asked to remove,
            # so the check after the uninstall sees the same state a real machine would.
            Mock Get-ItemProperty { return $script:registryEntries }
            Mock dotnet-core-uninstall {
                $removedVersion = $Arguments[1]
                $script:registryEntries = @($script:registryEntries | Where-Object { $_.DisplayName -notmatch "(^|[^\d.])$([regex]::Escape($removedVersion))([^\d.]|$)" })
            }

            function SetRegistryEntries([string[]]$DisplayNames)
            {
                $script:registryEntries = @($DisplayNames | ForEach-Object { [pscustomobject]@{ DisplayName = $_ } })
            }

            function AssertRemoved([string]$ExpectedArguments)
            {
                Assert-MockCalled -CommandName dotnet-core-uninstall -Times 1 -Exactly -Scope Context -ParameterFilter ([scriptblock]::Create("(`$Arguments -join ' ') -eq '$ExpectedArguments'"))
            }

            function AssertNotRemoved([string]$Version)
            {
                Assert-MockCalled -CommandName dotnet-core-uninstall -Times 0 -Exactly -Scope Context -ParameterFilter ([scriptblock]::Create("`$Arguments -contains '$Version'"))
            }

            $assNotRunBulkOptions = @{ 'CommandName' = 'dotnet-core-uninstall'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { ($Arguments -contains '--all-below') -or ($Arguments -contains '--all-but') -or ($Arguments -contains '--all-lower-patches') -or ($Arguments -contains '--all-but-latest') } }

            Context 'When hosting bundles older than .NET 6 are installed next to .NET 6 and the minimum version' {

                # The machine where removing 2.1.12 and 3.1.14 took the aspNetCore section out of applicationHost.config
                SetRegistryEntries @(
                    'Microsoft .NET Core 2.1.12 - Windows Server Hosting',
                    'Microsoft .NET Core 3.1.14 - Windows Server Hosting',
                    'Microsoft .NET 6.0.6 - Windows Server Hosting',
                    'Microsoft ASP.NET Core 6.0.6 Hosting Bundle Options',
                    'Microsoft .NET 8.0.0 - Windows Server Hosting',
                    'Microsoft ASP.NET Core 8.0.0 Hosting Bundle Options'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should remove the .NET 6 hosting bundle' { AssertRemoved 'remove 6.0.6 --hosting-bundle' }
                It 'Should not remove the .NET Core 2.1 hosting bundle' { AssertNotRemoved '2.1.12' }
                It 'Should not remove the .NET Core 3.1 hosting bundle' { AssertNotRemoved '3.1.14' }
                It 'Should not remove the minimum version' { AssertNotRemoved '8.0.0' }
                It 'Should not use the bulk removal options of the tool' { Assert-MockCalled @assNotRunBulkOptions }
                It 'Should report success' { $result | Should Be $true }
                It 'Should keep the hosting bundles older than .NET 6 installed' { @($script:registryEntries | Where-Object { $_.DisplayName -like '*Core 2.1.12*' -or $_.DisplayName -like '*Core 3.1.14*' }).Count | Should Be 2 }
            }

            Context 'When a newer patch than the minimum version is installed' {

                SetRegistryEntries @(
                    'Microsoft .NET 8.0.0 - Windows Server Hosting',
                    'Microsoft ASP.NET Core 8.0.0 Hosting Bundle Options',
                    'Microsoft .NET 8.0.2 - Windows Server Hosting',
                    'Microsoft ASP.NET Core 8.0.2 Hosting Bundle Options'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should remove the patch superseded by the newer one' { AssertRemoved 'remove 8.0.0 --hosting-bundle' }
                It 'Should keep the newer patch' { AssertNotRemoved '8.0.2' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET 11 is required and .NET 6 and .NET 8 are installed' {

                # The minimum version carries a revision that the package names do not have
                SetRegistryEntries @(
                    'Microsoft .NET 6.0.6 - Windows Server Hosting',
                    'Microsoft .NET 8.0.2 - Windows Server Hosting',
                    'Microsoft .NET 11.0.0 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '11.0.0.26529'

                It 'Should remove the .NET 6 hosting bundle' { AssertRemoved 'remove 6.0.6 --hosting-bundle' }
                It 'Should remove the .NET 8 hosting bundle' { AssertRemoved 'remove 8.0.2 --hosting-bundle' }
                It 'Should not remove the .NET 11 hosting bundle' { AssertNotRemoved '11.0.0' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET 11 is required and majors between .NET 6 and .NET 11 are installed' {

                SetRegistryEntries @(
                    'Microsoft .NET Core 3.1.14 - Windows Server Hosting',
                    'Microsoft .NET 7.0.20 - Windows Server Hosting',
                    'Microsoft .NET 10.0.1 - Windows Server Hosting',
                    'Microsoft .NET 11.0.0 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '11.0.0.26529'

                It 'Should remove the .NET 7 hosting bundle' { AssertRemoved 'remove 7.0.20 --hosting-bundle' }
                It 'Should remove the .NET 10 hosting bundle' { AssertRemoved 'remove 10.0.1 --hosting-bundle' }
                It 'Should not remove the .NET Core 3.1 hosting bundle' { AssertNotRemoved '3.1.14' }
                It 'Should not remove the .NET 11 hosting bundle' { AssertNotRemoved '11.0.0' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET 11 is required and two .NET 11 patches are installed' {

                # The .NET Uninstall Tool 1.7 cannot remove 11.0.0 and above, so the older patch is kept instead of failing the installation
                SetRegistryEntries @(
                    'Microsoft .NET 11.0.0 - Windows Server Hosting',
                    'Microsoft .NET 11.0.2 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '11.0.0.26529'

                It 'Should not run the tool' { Assert-MockCalled -CommandName dotnet-core-uninstall -Times 0 -Exactly -Scope Context }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET 8 is required and two .NET 8 patches are installed next to .NET 11' {

                SetRegistryEntries @(
                    'Microsoft .NET 8.0.0 - Windows Server Hosting',
                    'Microsoft .NET 8.0.2 - Windows Server Hosting',
                    'Microsoft .NET 11.0.0 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should remove the older .NET 8 patch' { AssertRemoved 'remove 8.0.0 --hosting-bundle' }
                It 'Should keep the newer .NET 8 patch' { AssertNotRemoved '8.0.2' }
                It 'Should keep .NET 11' { AssertNotRemoved '11.0.0' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET 6 is required and a newer major is installed' {

                SetRegistryEntries @(
                    'Microsoft .NET 6.0.6 - Windows Server Hosting',
                    'Microsoft .NET 8.0.2 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '6.0.6'

                It 'Should not run the tool' { Assert-MockCalled -CommandName dotnet-core-uninstall -Times 0 -Exactly -Scope Context }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When only packages older than .NET 6 are installed' {

                SetRegistryEntries @(
                    'Microsoft .NET Core 2.1.12 - Windows Server Hosting',
                    'Microsoft .NET Core 3.1.14 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should not run the tool' { Assert-MockCalled -CommandName dotnet-core-uninstall -Times 0 -Exactly -Scope Context }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When the tool does not remove a version' {

                Mock dotnet-core-uninstall {}

                SetRegistryEntries @(
                    'Microsoft .NET 6.0.6 - Windows Server Hosting',
                    'Microsoft .NET 8.0.0 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should try to remove it' { AssertRemoved 'remove 6.0.6 --hosting-bundle' }
                It 'Should log the version left as a warning' { Assert-MockCalled -CommandName LogMessage -Times 1 -Exactly -Scope Context -ParameterFilter { ($Stream -eq 1) -and ($Message -eq 'Could not remove --hosting-bundle 6.0.6') } }
                It 'Should report failure' { $result | Should Be $false }
            }

            Context 'When a preview is installed next to a release of the same major' {

                # The tool lists a preview under its preview version, so asking it to remove 10.0.0 would not find it
                SetRegistryEntries @(
                    'Microsoft .NET 10.0.0 Preview 7 Build preview.7.25380.108 - Windows Server Hosting',
                    'Microsoft .NET 10.0.1 - Windows Server Hosting'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '11.0.0.26529'

                It 'Should remove the release' { AssertRemoved 'remove 10.0.1 --hosting-bundle' }
                It 'Should not try to remove the preview' { AssertNotRemoved '10.0.0' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When a release candidate is installed' {

                # The tool lists a release candidate under its release version, as on the machine where 'RC 3 Build rc.3.26522.148' was listed as 11.0.0
                SetRegistryEntries @(
                    'Microsoft .NET 10.0.0 RC 2 Build rc.2.25502.107 - Windows Server Hosting',
                    'Microsoft ASP.NET Core 10.0.0 RC 2 Build rc.2.25502.107 Hosting Bundle Options'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '11.0.0.26529'

                It 'Should remove it by its release version' { AssertRemoved 'remove 10.0.0 --hosting-bundle' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When ASP.NET Core runtimes of several majors are installed' {

                SetRegistryEntries @(
                    'Microsoft ASP.NET Core 3.1.14 - Shared Framework (x64)',
                    'Microsoft ASP.NET Core 6.0.6 - Shared Framework (x64)',
                    'Microsoft ASP.NET Core 6.0.6 - Shared Framework (x86)',
                    'Microsoft ASP.NET Core 8.0.0 - Shared Framework (x64)'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--aspnet-runtime' -RecentVersion '8.0.0'

                It 'Should remove the .NET 6 runtime once for both architectures' { AssertRemoved 'remove 6.0.6 --aspnet-runtime' }
                It 'Should not remove the .NET Core 3.1 runtime' { AssertNotRemoved '3.1.14' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When .NET runtimes of several majors are installed' {

                SetRegistryEntries @(
                    'Microsoft .NET Core Runtime - 3.1.14 (x64)',
                    'Microsoft .NET Runtime - 6.0.6 (x64)',
                    'Microsoft .NET Runtime - 8.0.0 (x64)'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--runtime' -RecentVersion '8.0.0'

                It 'Should remove the .NET 6 runtime' { AssertRemoved 'remove 6.0.6 --runtime' }
                It 'Should not remove the .NET Core 3.1 runtime' { AssertNotRemoved '3.1.14' }
                It 'Should report success' { $result | Should Be $true }
            }

            Context 'When entries without a version or of other package types are installed' {

                SetRegistryEntries @(
                    'Microsoft ASP.NET Core Hosting Bundle Options',
                    'Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24215'
                )

                $result = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -RecentVersion '8.0.0'

                It 'Should not run the tool' { Assert-MockCalled -CommandName dotnet-core-uninstall -Times 0 -Exactly -Scope Context }
                It 'Should report success' { $result | Should Be $true }
            }
        }
    }
}
finally
{
    if (-not $stubExisted)
    {
        # 'function:global:...' does not remove it when run under Pester, the unqualified path does
        Remove-Item -Path 'function:\dotnet-core-uninstall'
    }
}
