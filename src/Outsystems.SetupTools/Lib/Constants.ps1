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
    "Web-Filtering", "Web-Windows-Auth", `
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
# .NET Framework version numbering: https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/release-keys-and-os-versions
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS10ReqsMinDotNetVersion = "394254"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS11ReqsMinDotNetVersion = "461808"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OS11ReqsMinDotNetCoreVersion = "2.1.11"

# Microsoft Build Tools 2015 MSI Product Code
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRequiredMSBuildProductCode = "{8C918E5B-E238-401F-9F6E-4FB84B024CA2}"

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
$OSRepoURL = "https://myfilerepo.blob.core.windows.net/sources"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURLDotNET = 'https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURLBuildTools = 'https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSRepoURLDotNETCore = 'https://download.visualstudio.microsoft.com/download/pr/0ad9d7d3-3cca-48e8-a5cc-07a5a6b8a020/820fd44b4eca9f31b11875d75068bb74/dotnet-hosting-2.1.11-win.exe'

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

# AzStorage
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSAzStorageAccountName = 'myfilerepo'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSAzStorageSASToken = 'nAFk4sFRvsisvgwfijMpi67fy6ZAw8yfPvJXeiqOLUc%3D'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSAzStorageContainer = 'sources'


# IIS configuration
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSIISConfig = @(
    @{
        'PoolName' = 'OutSystemsApplications';
        'MemoryPercentage' = 60;
        'Match' = @('*')
    },
    @{
        'PoolName' = 'ServiceCenterAppPool';
        'MemoryPercentage' = 100;
        'Match' = @('/ServiceCenter')
    },
    @{
        'PoolName' = 'LifeTimeAppPool';
        'MemoryPercentage' = 60;
        'Match' = @('/LT*','/lifet*','/LifeT*','PerformanceMonitor')
    }
)

# Performance Tuning
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxRequestLength=131072
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
[TimeSpan]$OSPerfTuningExecutionTimeout='00:01:50'
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxAllowedContentLength=134217728
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$OSPerfTuningMaxConnections=4294967295
