Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Get-OSPlatformDeploymentZone Tests' {

        $confToolOutput = @{
            Output   = '[{"Address" : "CIP-PJN-TEST-10.outsystemsrd.net","EnableHttps" : "False","Name" : "Global"}]'
            ExitCode = 0
        }

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetServerVersion { return '11.0.0.0' }
        Mock RunConfigTool { return $confToolOutput }

        $assNotRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }
        $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            Get-OSPlatformDeploymentZone -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When platform is not installed' {

            Mock GetServerInstallDir { return $null }
            Mock GetServerVersion { return $null }

            Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'OutSystems platform is not installed' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When platform is bellow OS 11' {

            Mock GetServerVersion { return '10.0.0.0' }

            Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'This cmdLet is only supported on OutSystems 11 or higher' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the cannot launch the configuration tool' {

            Mock RunConfigTool { throw 'big error' }

            Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error launching the configuration tool. Exit code: ' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the configuration tool returns an error' {

            $confToolOutput = @{
                ExitCode = 1
            }
            Mock RunConfigTool { return $confToolOutput }

            Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error getting the deployment zones. Exit code: 1' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When cannot parse the configuration output' {

            Mock ConvertFrom-Json { throw 'big error' }

            Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error converting the configuration tool output to object' }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the everything is successfull' {

            $result = Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue -ErrorVariable err

            $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq '/getdeploymentzones' }}

            It 'Should run the configuration tool' { Assert-MockCalled @assRunConfTool }
            It 'Address should have the right value' { $result.Address | Should Be 'CIP-PJN-TEST-10.outsystemsrd.net' }
            It 'EnableHttps should have the right value' { $result.EnableHttps | Should Be 'False' }
            It 'Name should have the right value' { $result.Name | Should Be 'Global' }
            It 'Should call the configuration tool with the right parameters' { $result.EnableHttps | Should Be 'False' }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Get-OSPlatformDeploymentZone -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
