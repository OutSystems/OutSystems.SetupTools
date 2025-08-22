. $PSScriptRoot\..\..\src\Outsystems.SetupTools\Lib\Constants.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Describe 'Lib Constants Tests' {

    Context 'Check .NET constants for OS11' {

        $MajorVersion = '11'
        $SavePath = "$env:TEMP\dotnet11.exe"
        $FileHash = '5CB624B97F9FD6D3895644C52231C9471CD88AACB57D6E198D3024A1839139F6'

        It 'Should have the right "Version"' { $script:OSDotNetReqForMajor[$MajorVersion]['Version'] | Should Be "4.7.2" }
        It 'Should have the right "Value"' { $script:OSDotNetReqForMajor[$MajorVersion]['Value'] | Should Be "461808" }
        It 'Should have the right "ToInstallVersion"' { $script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'] | Should Be "4.7.2" }
        It '"ToInstallDownloadURL" should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallDownloadURL'], $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }

    Context 'Check BuildTools constants' {

        $SavePath = "$env:TEMP\buildtools.exe"
        $FileHash = '92CFB3DE1721066FF5A93F14A224CC26F839969706248B8B52371A8C40A9445B'

        It 'Should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($OSRepoURLBuildTools, $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }
}
