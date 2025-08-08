# Outsystems services
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSServices = @(
    "OutSystems Log Service",
    "OutSystems Deployment Controller Service",
    "OutSystems Deployment Service",
    "OutSystems Scheduler Service",
    "OutSystems SMS Connector Service"
)

# Outsystems base Windows Features
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSWindowsFeaturesBase = @(
    "Web-Server",
    "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-Static-Content",
    "Web-Http-Logging", "Web-Request-Monitor",
    "Web-Stat-Compression", "Web-Dyn-Compression",
    "Web-Filtering", "Web-Windows-Auth",
    "Web-Net-Ext45", "Web-Asp-Net45", "Web-ISAPI-Ext", "Web-ISAPI-Filter",
    "Web-Metabase",
    "WAS-Config-APIs", "WAS-Process-Model"
)

# Hardware requirements
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS10ReqsMinCores = 2
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS10ReqsMinRAMGB = 4
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS11ReqsMinCores = 2
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS11ReqsMinRAMGB = 4

# Software and operating system requirements
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS10ReqsMinOSVersion = "6.2.0.0"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS11ReqsMinOSVersion = "10.0.14393"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSReqsMinOSProductType = 2

# Microsoft Build Tools 2015 MSI Product Codes

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
# [version 14.0.23107]    ->  2015
$OSReqsMSBuild2015ProductCode = "{8C918E5B-E238-401F-9F6E-4FB84B024CA2}"

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
# [version 14.0.24720]    ->  2015 Update 1
$OSReqsMSBuild2015u1ProductCode = "{477F7BAD-67AD-4E4F-B704-4AF4F44CB9BD}"

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
# [version 14.0.25123]    ->  2015 Update 2
$OSReqsMSBuild2015u2ProductCode = "{DF27D91D-516E-4DA1-92AC-7D7D59B2D99E}"

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
# [version 14.0.25420.1]  ->  2015 Update 3
$OSReqsMSBuild2015u3ProductCode = "{79750C81-714E-45F2-B5DE-42DEF00687B8}"

# Windows event log configs
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSWinEventLogSize = 20480KB
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSWinEventLogOverflowAction = "OverwriteAsNeeded"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSWinEventLogName = @(
    "Security",
    "Application",
    "System"
)
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSWinEventLogAutoBackup = "AutoBackupLogFiles"

# Default install directories
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSDefaultInstallDir = "$Env:ProgramFiles\OutSystems"

# Default Service Center credentials
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSSCUser = "admin"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSSCPass = "admin"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSSCCred = New-Object System.Management.Automation.PSCredential ($OSSCUser, $(ConvertTo-SecureString $OSSCPass -AsPlainText -Force))

# Sources download URLs
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURL = "https://ossetuptools.blob.core.windows.net/sources"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURLBuildTools = 'https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURLMSVCppRedist = 'https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/CC0FF0EB1DC3F5188AE6300FAEF32BF5BEEBA4BDD6E8E445A9184072096B713B/VC_redist.x64.exe'

# Microsoft Visual C++ 2015-2022 Redistributable related
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
# First version of the 2015-2022 Redistributable
$OSReqsMSVCppRedistFirstVersion = [version]'14.30.30708.0'

# .NET related
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSDotNetReqForMajor = @{
    '10' = @{
        Version              = '4.6.1'
        Value                = '394254'
        ToInstallVersion     = '4.7.2'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe'
    }
    '11' = @{
        Version              = '4.7.2'
        Value                = '461808'
        ToInstallVersion     = '4.7.2'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe'
    }
    '12' = @{
        Version              = '4.7.2'
        Value                = '461808'
        ToInstallVersion     = '4.7.2'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe'
    }
}

# .NET Core Hosting Bundle related
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSDotNetCoreHostingBundleReq = @{
    '2' = @{
        Version = '2.1.12'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/eebd54bc-c3a2-4580-bb29-b35c1c5ffa92/22ffe5649861167d3d5728d3cb4b10a1/dotnet-hosting-2.1.12-win.exe'
        InstallerName = 'DotNetCore_WindowsHosting.exe'
    }
    '3' = @{
        Version = '3.1.14'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/bdc70151-74f7-427c-a368-716d5f1840c5/6186889f6c784bae224eb15fb94c45fe/dotnet-hosting-3.1.14-win.exe'
        InstallerName = 'DotNetCore_WindowsHosting_31.exe'
    }
    '6' = @{
        Version = '6.0.6'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/0d000d1b-89a4-4593-9708-eb5177777c64/cfb3d74447ac78defb1b66fd9b3f38e0/dotnet-hosting-6.0.6-win.exe'
        InstallerName = 'DotNet_WindowsHosting_6.exe'
    }
    '8' = @{
        Version = '8.0.0'
        ToInstallDownloadURL = 'https://download.visualstudio.microsoft.com/download/pr/2a7ae819-fbc4-4611-a1ba-f3b072d4ea25/32f3b931550f7b315d9827d564202eeb/dotnet-hosting-8.0.0-win.exe'
        InstallerName = 'DotNet_WindowsHosting_8.exe'
    }
}

# .NET Core Uninstall Tool related
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSDotNetCoreUninstallReq = @{
    '1.5' = @{
        Version = '1.5.255402'
        ToInstallDownloadURL = 'https://github.com/dotnet/cli-lab/releases/download/1.5.255402/dotnet-core-uninstall-1.5.255402.msi'
        InstallerName = 'DotNetCore_Uninstall_15.msi'
    }
}

# Database default timeout
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSDBTimeout = "60"

# Log related
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSLogFile = ""
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSLogDebug = $false
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSEnableLogTemplate = $true

# RabbitMQ related. installDir is set on the Install-RabbitMQ cmdLet cause it depends on where the plaform is installed
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRabbitMQBaseDir = "$ENV:ALLUSERSPROFILE\RabbitMQ"

# Telemetry
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSTelAppInsightsKeys = @('91943ce0-af45-4b7c-a40d-0018e4072e8a')
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSTelTier = 'Standard'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSTelEnabled = $true
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSTelSessionId = ''
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSTelOperationId = ''

# IIS configuration
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSIISConfig = @(
    @{
        'PoolName'         = 'OutSystemsApplications';
        'MemoryPercentage' = 60;
        'Match'            = @('*')
    },
    @{
        'PoolName'         = 'ServiceCenterAppPool';
        'MemoryPercentage' = 100;
        'Match'            = @('/ServiceCenter')
    },
    @{
        'PoolName'         = 'LifeTimeAppPool';
        'MemoryPercentage' = 60;
        'Match'            = @('/LT*', '/lifet*', '/LifeT*', '/PerformanceMonitor')
    }
)
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSIISConfigExcludedApps = ( '/server.api', '/server.identity' )

# Performance Tuning
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxRequestLength = 262144
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
[TimeSpan]$OSPerfTuningExecutionTimeout = '00:01:50'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxAllowedContentLength = 268435456
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxConnections = 4294967295