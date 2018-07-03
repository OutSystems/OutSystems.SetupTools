# Outsystems services
$OSServices = @(
    "OutSystems Log Service",
    "OutSystems Deployment Controller Service",
    "OutSystems Deployment Service",
    "OutSystems Scheduler Service",
    "OutSystems SMS Connector Service"
)

# Outsystems base windows features
$OSWindowsFeaturesBase = @(
    "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-Static-Content",
    "Web-Http-Logging", "Web-Request-Monitor",
    "Web-Stat-Compression", "Web-Dyn-Compression",
    "Web-Filtering", "Web-Windows-Auth", `
    "Web-Net-Ext45", "Web-Asp-Net45", "Web-ISAPI-Ext", "Web-ISAPI-Filter",
    "Web-Metabase",
    "WAS-Config-APIs", "WAS-Process-Model"
)

# Hardware requirements
$OSReqsMinCores = 2
$OSReqsMinRAMGB = 4

# Software and operating system requirements
$OSReqsMinOSVersion = "6.1.0.0"
$OSReqsMinOSProductType = 2
$OSReqsMinDotNetVersion = "394254"

# Windows event log configs
$OSWinEventLogSize = 20480KB
$OSWinEventLogOverflowAction = "OverwriteAsNeeded"
$OSWinEventLogName = @(
    "Security",
    "Application",
    "System"
)

# Default install directories
$OSDefaultInstallDir = "$Env:ProgramFiles\OutSystems"

# Default Service Center credentials
$OSSCUser = "admin"
$OSSCPass = "admin"

# Sources repo
$OSRepoURL = "https://myfilerepo.blob.core.windows.net/sources"

# Database default timeout
$OSDBTimeout = "60"

# Log related
$LogFile = ""
$LogDebug = $false
