Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Set-OSPlatformDeploymentZone Tests' {

        $confToolOutput = @{
            ExitCode = 0
        }

        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }
        Mock GetServerVersion { return '12.0.0.0' }
        Mock RunConfigTool { return $confToolOutput }

        $assNotRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context' }
        $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context' }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When platform is not installed' {

            Mock GetServerInstallDir { return $null }
            Mock GetServerVersion { return $null }

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'OutSystems platform is not installed' }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When platform is bellow OS 11' {

            Mock GetServerVersion { return '10.0.0.0' }

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should not run the configuration tool' { Assert-MockCalled @assNotRunConfTool }
            It 'Should output an error' { $err[-1] | Should Be 'This cmdLet is only supported on OutSystems 11 or higher' }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the cannot launch the configuration tool' {

            Mock RunConfigTool { throw 'big error' }

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error launching the configuration tool. Exit code: ' }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the configuration tool returns an error' {

            $confToolOutput = @{
                ExitCode = 1
            }
            Mock RunConfigTool { return $confToolOutput }

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue -ErrorVariable err

            It 'Should output an error' { $err[-1] | Should Be 'Error setting the deployment zones. Exit code: 1' }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the everything is successfull and only the ZoneAddress parameters is specified' {

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue -ErrorVariable err

            $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq '/modifydeploymentzone Global 8.8.8.8' }}

            It 'Should run the configuration tool with the right parameters' { Assert-MockCalled @assRunConfTool }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the everything is successfull and the ZoneAddress and the DeploymentZone is specified' {

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -DeploymentZone 'myzone' -ErrorAction SilentlyContinue -ErrorVariable err

            $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq '/modifydeploymentzone myzone 8.8.8.8' }}

            It 'Should run the configuration tool with the right parameters' { Assert-MockCalled @assRunConfTool }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -DeploymentZone 'myzone' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When the everything is successfull and the ZoneAddress, DeploymentZone and EnableHTTPS is specified' {

            Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -DeploymentZone 'myzone' -EnableHTTPS:$true -ErrorAction SilentlyContinue -ErrorVariable err

            $assRunConfTool = @{ 'CommandName' = 'RunConfigTool'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'; 'ParameterFilter' = { $Arguments -eq '/modifydeploymentzone myzone 8.8.8.8 True' }}

            It 'Should run the configuration tool with the right parameters' { Assert-MockCalled @assRunConfTool }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8 -DeploymentZone 'myzone' -EnableHTTPS:$true -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
