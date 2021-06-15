. $PSScriptRoot\..\..\src\Outsystems.SetupTools\Lib\Constants.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Describe 'Lib Constants Tests' {

    Context 'Check .NET constants for OS12' {

        $MajorVersion = '12'
        $SavePath = "$env:TEMP\dotnet12.exe"
        $FileHash = 'C908F0A5BEA4BE282E35ACBA307D0061B71B8B66CA9894943D3CBB53CAD019BC'

        It 'Should have the right "Version"' { $script:OSDotNetReqForMajor[$MajorVersion]['Version'] | Should Be "4.7.2" }
        It 'Should have the right "Value"' { $script:OSDotNetReqForMajor[$MajorVersion]['Value'] | Should Be "461808" }
        It 'Should have the right "ToInstallVersion"' { $script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'] | Should Be "4.7.2" }
        It '"ToInstallDownloadURL" should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallDownloadURL'], $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }

    Context 'Check .NET constants for OS11' {

        $MajorVersion = '11'
        $SavePath = "$env:TEMP\dotnet11.exe"
        $FileHash = 'C908F0A5BEA4BE282E35ACBA307D0061B71B8B66CA9894943D3CBB53CAD019BC'

        It 'Should have the right "Version"' { $script:OSDotNetReqForMajor[$MajorVersion]['Version'] | Should Be "4.7.2" }
        It 'Should have the right "Value"' { $script:OSDotNetReqForMajor[$MajorVersion]['Value'] | Should Be "461808" }
        It 'Should have the right "ToInstallVersion"' { $script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'] | Should Be "4.7.2" }
        It '"ToInstallDownloadURL" should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallDownloadURL'], $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }

    Context 'Check .NET constants for OS10' {

        $MajorVersion = '10'
        $SavePath = "$env:TEMP\dotnet10.exe"
        $FileHash = 'C908F0A5BEA4BE282E35ACBA307D0061B71B8B66CA9894943D3CBB53CAD019BC'

        It 'Should have the right "Version"' { $script:OSDotNetReqForMajor[$MajorVersion]['Version'] | Should Be "4.6.1" }
        It 'Should have the right "Value"' { $script:OSDotNetReqForMajor[$MajorVersion]['Value'] | Should Be "394254" }
        It 'Should have the right "ToInstallVersion"' { $script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'] | Should Be "4.7.2" }
        It '"ToInstallDownloadURL" should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallDownloadURL'], $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }

    Context 'Check .NETCore 2.1 constants' {

        $SavePath = "$env:TEMP\dotnetcore21.exe"
        $FileHash = 'AC74CADB690D3A5A175CEDD0EF02A11ABE41A292F9C9055B28522E3EB7B02726'

        It 'Should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetCoreHostingBundleReq['2']['ToInstallDownloadURL'], $SavePath)
            $(Get-FileHash -Path $SavePath).Hash | Should Be $FileHash
        }
    }

    Context 'Check .NETCore 3.1 constants' {

        $SavePath = "$env:TEMP\dotnetcore.exe"
        $FileHash = '187179215D0C9DE82F6C6F005E08AC517E34E9689959964053B0F60FEDFD8302'

        It 'Should be downloadable and have the right file hash' {
            (New-Object System.Net.WebClient).DownloadFile($script:OSDotNetCoreHostingBundleReq['3']['ToInstallDownloadURL'], $SavePath)
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
