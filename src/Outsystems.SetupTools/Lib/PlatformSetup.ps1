<#
    SetupFunctions

    Coding guidelines:
    "Get" functions should not throw errors. Should send the result or an empty result
    "Set" functions should ALWAYS throw terminating errors. The caller should try/catch.
    "Install/Invoke" functions should throw terminating errors if they cannot start.
    "Install/Invoke" functions return the exit code to the caller if they can start. The caller should decide what to do with the exit code.
    LogMessage should always send to the debug stream (-Phase 1 -Stream 2)
#>

function InstallWindowsFeatures([string[]]$Features)
{
    $ProgressPreference = "SilentlyContinue"
    $installResult = Install-WindowsFeature -Name $Features -ErrorAction SilentlyContinue -Verbose:$false -WarningAction SilentlyContinue

    return $installResult
}

function GetWindowsFeatureState([string]$Features)
{
    return $($(Get-WindowsFeature -Name $Features -Verbose:$false).Installed)
}

function ServiceWindowsSearchIsDisabled()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking Windows Search Service status."
    $WSearchService = $(Get-Service -Name "WSearch" -ErrorAction SilentlyContinue)
    return ($null -eq $WSearchService) -or ($($WSearchService.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Stopped) -and $($WSearchService.StartType -eq [System.ServiceProcess.ServiceStartMode]::Disabled))
}

function ConfigureServiceWindowsSearch()
{
    if ($(Get-Service -Name "WSearch" -ErrorAction SilentlyContinue))
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Disabling the Windows search service."
        Set-Service -Name "WSearch" -StartupType "Disabled" -ErrorAction Stop

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Stopping the Windows search service."
        Get-Service -Name "WSearch" | Stop-Service -ErrorAction Stop
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Service not found. Skipping."
    }
}

function ServiceWMIIsEnabled()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking WMI Service status."
    $WSearchService = $(Get-Service -Name "Winmgmt" -ErrorAction SilentlyContinue)
    return $($WSearchService.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) -and $($WSearchService.StartType -eq [System.ServiceProcess.ServiceStartMode]::Automatic)
}

function ConfigureServiceWMI()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the WMI windows service and changing the startup type to automatic."
    Set-Service -Name "Winmgmt" -StartupType "Automatic" -ErrorAction Stop | Start-Service -ErrorAction Stop
}

function IsFIPSDisabled
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting registry value for HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled"
    return $(RegRead -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Name "Enabled") -eq 0
}

function DisableFIPS
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled = 0"
    RegWrite -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Name "Enabled" -Value 0 -Type "DWORD"
}

function ConfigureMSMQDomainServer
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\AlwaysWithoutDS = 1"
    RegWrite -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -Name "AlwaysWithoutDS" -Value 1 -Type "DWORD"
}

function ConfigureWindowsEventLog([string]$LogName, [string]$LogSize, [string]$LogOverflowAction)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting event log $LogName with maxsize of $LogSize and $LogOverflowAction"
    Limit-EventLog -MaximumSize $LogSize -OverflowAction $LogOverflowAction -LogName $LogName -ErrorAction Stop
}

function GetDotNet4Version()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the registry value HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\<langid>\Release."

    <#
        RPD-4212: For Windows installations with Japanese language, registry has two entries located at
        'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\'. Thus Installer fails later in Get-OSServerPreReqs.ps1
        because it is comparing two number against one in -ge operation, then in CreateResult it will always generate NOK message
        leading to a fail pre-requisites check and, as consequence, fail Platform installation.
        To prevent this, we need to sort, in descending order, the retrieved values and return the first element.
    #>
    try
    {
        $output = $(Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction Stop | Get-ItemProperty -ErrorAction Stop).Release | Sort-Object -Descending | Select-Object -First 1
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetWindowsServerHostingVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\WOW6432Node\Microsoft\Updates\.NET Core\Microsoft .Net Core<*>Windows Server Hosting<*>\PackageVersion"

    $rootPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Updates\.NET Core'
    $filter = 'Microsoft .Net Core*Windows Server Hosting*'

    try
    {
        $version = $(Get-ChildItem -Path $rootPath -ErrorAction Stop | Where-Object { $_.PSChildName -like $filter } | Get-ItemProperty -ErrorAction Stop).PackageVersion | Sort-Object -Descending | Select-Object -First 1
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    if (-not $version)
    {
        $version = '0.0.0.0'
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $version"

    return $version
}

function InstallDotNet([string]$Sources, [string]$URL)
{
    if ($Sources)
    {
        if (Test-Path "$Sources\DotNet.exe")
        {
            $installer = "$Sources\DotNet.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local file: $installer"
        }
        # If Windows is set to hide file extensions from file names, the file could have been stored with double extension by mistake.
        elseif (Test-Path "$Sources\DotNet.exe.exe")
        {
            $installer = "$Sources\DotNet.exe.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local fallback file: $installer"
        }
        else {
            throw [System.IO.FileNotFoundException] "DotNet.exe not found."
        }
    }
    else
    {
        $installer = "$ENV:TEMP\DotNet.exe"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $URL"
        DownloadOSSources -URL $URL -SavePath $installer
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $installer -ArgumentList "/q", "/norestart", "/MSIOPTIONS `"ALLUSERS=1 REBOOT=ReallySuppress`"" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returning $($result.ExitCode)"

    return $($result.ExitCode)
}

function GetDotNetLimits
{
    $NETConfig = @{ }
    $NETConfig.SystemWeb = @{ }
    $NETConfig.SystemWeb.HttpRuntime = @{ }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Opening the config file"
    $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting current .NET maximum request size"
    $NETConfig.SystemWeb.HttpRuntime.maxRequestLength = $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting current .NET execution timeout"
    $NETConfig.SystemWeb.HttpRuntime.executionTimeout = $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout

    return $NETConfig
}

function SetDotNetLimits([int]$UploadLimit, [TimeSpan]$ExecutionTimeout)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Opening the config file"
    $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting .NET maximum request size (maxRequestLength = $UploadLimit)"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = $UploadLimit

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting .NET execution timeout (executionTimeout = $($ExecutionTimeout.TotalSeconds) seconds)"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = $ExecutionTimeout

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Saving config"
    $NETMachineConfig.Save()
}

function GetMSBuildToolsInstallInfo
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Opening the config file"

    $InstallInfo = @{ }

    $InstallInfo.HasMSBuild2015 = $False
    $InstallInfo.HasMSBuild2017 = $False

    $InstallInfo.LatestVersionInstalled = $Null

    $InstallInfo.RebootNeeded = $False

    # We need to check each version.

    # Note that, while not brilliant, the checks should be ordered
    # by ascending MS Build Tools version

    if (IsMSIInstalled -ProductCode $OSReqsMSBuild2015ProductCode)
    {
        $InstallInfo.LatestVersionInstalled = "Build Tools 2015"

        $InstallInfo.HasMSBuild2015 = $True

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "$($InstallInfo.LatestVersionInstalled) is installed."
    }

    if (IsMSIInstalled -ProductCode $OSReqsMSBuild2015u1ProductCode)
    {
        $InstallInfo.LatestVersionInstalled = "Build Tools 2015 Update 1"

        $InstallInfo.HasMSBuild2015 = $True

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "$($InstallInfo.LatestVersionInstalled) is installed."
    }

    if (IsMSIInstalled -ProductCode $OSReqsMSBuild2015u2ProductCode)
    {
        $InstallInfo.LatestVersionInstalled = "Build Tools 2015 Update 2"

        $InstallInfo.HasMSBuild2015 = $True

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "$($InstallInfo.LatestVersionInstalled) is installed."
    }

    if (IsMSIInstalled -ProductCode $OSReqsMSBuild2015u3ProductCode)
    {
        $InstallInfo.LatestVersionInstalled = "Build Tools 2015 Update 3"

        $InstallInfo.HasMSBuild2015 = $True

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "$($InstallInfo.LatestVersionInstalled) is installed."
    }

    $isRebootRequired = GetMSBuildToolsInstallInfoWithVSWhere -MinVersion 15.0 -MaxVersion 17.0 -PropertyFilter "isRebootRequired"

    # If something other than $null is returned, we know vswhere found a valid version
    if ($null -ne $isRebootRequired)
    {
        $InstallInfo.LatestVersionInstalled = "Build Tools 2017"

        $InstallInfo.HasMSBuild2017 = $True

        $InstallInfo.RebootNeeded = ($isRebootRequired -eq '1')

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "$($InstallInfo.LatestVersionInstalled) is installed."
    }

    if ($null -eq $InstallInfo.LatestVersionInstalled)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Unable to detect a MSBuild Tools 2015 installation or current installation product code does not match the expected product codes:
        $OSReqsMSBuild2015ProductCode for MS Build Tools 2015,
        $OSReqsMSBuild2015u1ProductCode for MS Build Tools 2015 update 1,
        $OSReqsMSBuild2015u2ProductCode for MS Build Tools 2015 update 2,
        $OSReqsMSBuild2015u3ProductCode for MS Build Tools 2015 update 3."
    }

    return $InstallInfo
}

function IsMSBuildToolsVersionValid([string]$MajorVersion, [object]$InstallInfo)
{
    # Determines if we have a required version for the Major Version.
    switch ($MajorVersion)
    {
        '10'
        {
            # Has either MSBuildTools 2015
            # But _DOES NOT HAVE_ MSBuildTools 2017
            return ($InstallInfo.HasMSBuild2015) -and (-not $InstallInfo.HasMSBuild2017)
        }

        '11'
        {
            # Has either MSBuildTools 2015 or MSBuildTools 2017
            return ($InstallInfo.HasMSBuild2015 -or $InstallInfo.HasMSBuild2017)
        }

        default
        {
            return $False
        }
    }
}

function GetMSBuildToolsInstallInfoWithVSWhere([string]$MinVersion, [string]$MaxVersion, [string]$PropertyFilter)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using VSWhere to check if a MS Build Tools is installed version (between min. version $MinVersion and max. version $MaxVersion)."

    $VSWherePath = "$PSScriptRoot\Executables\vswhere.exe"

    if (-not (Test-Path $VSWherePath))
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "VWhere executable not found."

        return $null
    }

    if ([version]$MinVersion -ge [version]$MaxVersion)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Cannot pass to VSWhere a minimum version ($MinVersion) equal or greater than the maximum version ($MaxVersion)."

        return $null
    }

    $Requirements = @("Microsoft.Net.Component.4.6.1.SDK", "Microsoft.Net.Component.4.6.1.TargetingPack", "Microsoft.Component.MSBuild")
    $Versions = "[$MinVersion,$MaxVersion)"

    $Arguments = "-latest -products * -requires $($Requirements -join ' ') -version $Versions "

    if ($PropertyFilter)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "VSWhere will filter by property ($PropertyFilter)."

        $Arguments += "-property $PropertyFilter"
    }

    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $VSWherePath
    $ProcessInfo.RedirectStandardError = $true
    $ProcessInfo.RedirectStandardOutput = $true
    $ProcessInfo.UseShellExecute = $false
    $ProcessInfo.Arguments = "$Arguments"
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    $Process.Start() | Out-Null
    $Process.WaitForExit()
    $output = $Process.StandardOutput.ReadToEnd()

    if ($output -eq "")
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Output from VSWhere is empty."

        $output = $null
    }
    else
    {
        $output = $output.Trim()
    }

    return $output
}

function InstallBuildTools([string]$Sources)
{
    if ($Sources)
    {
        if (Test-Path "$Sources\BuildTools_Full.exe")
        {
            $installer = "$Sources\BuildTools_Full.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local file: $installer"
        }
        # If Windows is set to hide file extensions from file names, the file could have been stored with double extension by mistake.
        elseif (Test-Path "$Sources\BuildTools_Full.exe.exe")
        {
            $installer = "$Sources\BuildTools_Full.exe.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local fallback file: $installer"
        }
        else {
            throw [System.IO.FileNotFoundException] "BuildTools_Full.exe not found."
        }
    }
    else
    {
        $installer = "$ENV:TEMP\BuildTools_Full.exe"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLBuildTools"
        DownloadOSSources -URL $OSRepoURLBuildTools -SavePath $installer
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $installer -ArgumentList "-quiet" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returning $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallDotNetCore([string]$Sources)
{
    if ($Sources)
    {
        if (Test-Path "$Sources\DotNetCore_WindowsHosting.exe")
        {
            $installer = "$Sources\DotNetCore_WindowsHosting.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local file: $installer"
        }
        # If Windows is set to hide file extensions from file names, the file could have been stored with double extension by mistake.
        elseif (Test-Path "$Sources\DotNetCore_WindowsHosting.exe.exe")
        {
            $installer = "$Sources\DotNetCore_WindowsHosting.exe.exe"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Using local fallback file: $installer"
        }
        else {
            throw [System.IO.FileNotFoundException] "DotNetCore_WindowsHosting.exe not found."
        }
    }
    else
    {
        $installer = "$ENV:TEMP\DotNetCore_WindowsHosting.exe"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLDotNETCore"
        DownloadOSSources -URL $OSRepoURLDotNETCore -SavePath $installer
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $installer -ArgumentList "/install", "/quiet", "/norestart" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returnig $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallErlang([string]$InstallDir, [string]$Sources)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"

    $result = Start-Process -FilePath $Sources -ArgumentList "/S", "/D=$InstallDir" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returnig $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallRabbitMQ([string]$InstallDir, [string]$Sources)
{

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"

    # This needed to be like this because the rabbit installer is buggy and hangs the Start-Process!!
    $proc = Start-Process -FilePath $Sources -ArgumentList "/S", "/D=$InstallDir" -Wait:$false -PassThru -ErrorAction Stop
    Wait-Process $proc.Id
    $intReturnCode = $proc.ExitCode

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished"

    return $intReturnCode
}

function InstallRabbitMQPreReqs([string]$RabbitBaseDir)
{
    # Create the rabbitMQ base dir if doesnt exist
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Creating rabbitMQ base dir: $RabbitBaseDir"
    if (-not (Test-Path -Path $RabbitBaseDir))
    {
        New-Item -Path $RabbitBaseDir -ItemType directory -Force -ErrorAction Stop | Out-Null
    }

    # Set rabbitMQ base system wide and for this session
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting rabbitMQ base dir to $RabbitBaseDir"
    [System.Environment]::SetEnvironmentVariable('RABBITMQ_BASE', $RabbitBaseDir, "Machine")
    $ENV:RABBITMQ_BASE = $RabbitBaseDir

    # Enable the REST API for configuration
    Set-Content "$RabbitBaseDir\enabled_plugins" -Value '[rabbitmq_management].' -Force -ErrorAction Stop

    # Restrict management to localhost
    Set-Content "$RabbitBaseDir\rabbitmq.conf" -Value 'management.listener.port = 15672' -Force -ErrorAction Stop
    Add-Content "$RabbitBaseDir\rabbitmq.conf" -Value 'management.listener.ip   = 127.0.0.1' -Force -ErrorAction Stop
}

function GetErlangInstallDir()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the registry value HKLM:SOFTWARE\WOW6432Node\Ericsson\Erlang\<version>\default"
    try
    {
        $output = $(Get-ChildItem "HKLM:SOFTWARE\WOW6432Node\Ericsson\Erlang\" -ErrorAction Stop | Get-ItemProperty -ErrorAction Stop)."(default)"
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetRabbitInstallDir()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the registry value HKLM:SOFTWARE\WOW6432Node\VMware, Inc.\RabbitMQ Server\Install_Dir"
    $output = RegRead -Path "HKLM:SOFTWARE\WOW6432Node\VMware, Inc.\RabbitMQ Server" -Name "Install_Dir"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function IsMSIInstalled([string]$ProductCode)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking product code $ProductCode"
    try
    {
        $objInstaller = New-Object -ComObject WindowsInstaller.Installer
        $objType = $objInstaller.GetType()
        $Products = $objType.InvokeMember('Products', [System.Reflection.BindingFlags]::GetProperty, $null, $objInstaller, $null)
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    if ($Products -match $ProductCode)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning true"

        return $true
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning false"

        return $false
    }
}

function GetNumberOfCores()
{
    $computerSystemClass = Get-CimInstance -Class Win32_ComputerSystem -Verbose:$false
    $numOfCores = $computerSystemClass.NumberOfLogicalProcessors

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $numOfCores"

    return $NumOfCores
}

function GetInstalledRAM()
{
    $computerSystemClass = Get-CimInstance -Class Win32_ComputerSystem -Verbose:$false
    $installedRAM = $computerSystemClass.TotalPhysicalMemory
    $installedRAM = $installedRAM / 1GB

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $installedRAM GB"

    return $installedRAM
}

function GetOperatingSystemVersion()
{
    $operatingSystemClass = Get-CimInstance -Class Win32_OperatingSystem -Verbose:$false
    $osVersion = $operatingSystemClass.Version

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $osVersion"

    return $osVersion
}

function GetOperatingSystemProductType()
{
    $operatingSystemClass = Get-CimInstance -Class Win32_OperatingSystem -Verbose:$false
    $osProductType = $operatingSystemClass.ProductType

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $osProductType"

    return $osProductType
}

Function RunConfigTool([string]$Arguments, [scriptblock]$OnLogEvent)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Check if the file machine.config is locked before running the tool."
    $MachineConfigFile = "$ENV:windir\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"

    While (TestFileLock($MachineConfigFile))
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File is locked!! Retrying is 10s."
        Start-Sleep -Seconds 10
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running the config tool..."

    $Result = ExecuteCommand -CommandPath "$InstallDir\ConfigurationTool.com" -WorkingDirectory $InstallDir -CommandArguments "$Arguments" -OnLogEvent $OnLogEvent
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($Result.ExitCode)"

    Return $Result
}

function RunSCInstaller([string]$Arguments, [scriptblock] $OnLogEvent)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $installDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running SCInstaller..."

    #SCInstaller needs to run inside a CMD or will not return an exit code
    $result = ExecuteCommand -CommandPath "$env:comspec" -WorkingDirectory $installDir -CommandArguments "/c SCInstaller.exe $Arguments && exit /b %ERRORLEVEL%" -OnLogEvent $OnLogEvent -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($result.ExitCode)"

    return $result
}

function PublishSolution([string]$Solution, [string]$SCUser, [string]$SCPass, [scriptblock]$OnLogEvent)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Solution path: $Solution"
    $result = RunOSPTool -Arguments $("/publish " + [char]34 + $("$Solution") + [char]34 + " $ENV:ComputerName $SCUser $SCPass") -OnLogEvent $OnLogEvent

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($result.ExitCode)"

    return $result
}

function RunOSPTool([string]$Arguments, [scriptblock]$OnLogEvent)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $installDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server major version"
    $version = [System.Version]$(GetServerVersion)
    if ($version.Minor -eq 0)
    {
        $majorVersion = "$($version.Major).$($version.Minor)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Found old versioning. Server major version is $majorVersion"
    }
    else
    {
        $majorVersion = "$($version.Major)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Server major version is $majorVersion"
    }

    $ospToolPath = "$ENV:CommonProgramFiles\OutSystems\$majorVersion"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "OSPTool path is $ospToolPath"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running the OSPTool..."

    $result = ExecuteCommand -CommandPath "$ospToolPath\OSPTool.com" -WorkingDirectory $installDir -CommandArgument $Arguments -OnLogEvent $OnLogEvent

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Return code: $($result.ExitCode)"

    return $result
}

function GetServerInstallDir()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\(Default)"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "(default)"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetServerMachineName()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Platform Server\MachineName"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Platform Server" -Name "MachineName"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetServerSerialNumber()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Platform Server\SerialNumber"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Platform Server" -Name "SerialNumber"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetServiceStudioInstallDir([string]$MajorVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\(default)"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "(default)" #TODO: Add .0 here

    if ($output)
    {
        $output = $output.Replace("\Service Studio", "")
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"
    return $output
}

function GetServerVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Server"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Server"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"

    return $output
}

function GetServiceStudioVersion([string]$MajorVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\Service Studio $MajorVersion"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "Service Studio $MajorVersion"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"

    return $output
}

function DownloadOSSources([string]$URL, [string]$SavePath)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Download sources from $URL"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Save sources to $SavePath"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile($URL, $SavePath)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File successfully downloaded!"
}

Function ExecuteCommand([string]$CommandPath, [string]$WorkingDirectory, [string]$CommandArguments, [scriptblock]$OnLogEvent)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Launching the process $CommandPath with the arguments $CommandArguments"

    Try
    {
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = $CommandPath
        $ProcessInfo.RedirectStandardError = $true
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.Arguments = $CommandArguments
        $ProcessInfo.WorkingDirectory = $WorkingDirectory

        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null
        $Process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle

        if ($OnLogEvent)
        {
            do
            {
                # Keep redirecting output until process exits
                $OnLogEvent.Invoke($process.StandardOutput.ReadLine());

            } until ($process.HasExited)
        }

        $Process.WaitForExit()

        Return [PSCustomObject]@{
            ExitCode = $Process.ExitCode
        }
    }
    Catch
    {
        Throw "Error launching the process $CommandPath $CommandArguments"
    }
}

function GetSCCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\ServiceCenter"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "ServiceCenter"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"

    return $output
}

function SetSCCompiledVersion([string]$SCVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\ServiceCenter = $SCVersion"
    RegWrite -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "ServiceCenter" -Value $SCVersion -Type "String"
}

function GetSysComponentsCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\SystemComponents"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "SystemComponents"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"

    return $output
}

function SetSysComponentsCompiledVersion([string]$SysComponentsVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\SystemComponents = $SysComponentsVersion"
    RegWrite -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "SystemComponents" -Value $SysComponentsVersion -Type "String"
}

function GetLifetimeCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Lifetime"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Lifetime"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"

    return $output
}

function SetLifetimeCompiledVersion([string]$LifetimeVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\Lifetime = $LifetimeVersion"
    RegWrite -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Lifetime" -Value $LifetimeVersion -Type "String"
}

function GenerateEncryptKey()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Generating a new encrypted key"
    $key = [OutSystems.HubEdition.RuntimePlatform.NewRuntime.Authentication.Keys]::GenerateEncryptKey()

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returnig $key"

    return $key
}

function GetPlatformVersion([string]$SCHost)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting platform version from $SCHost"

    $result = SCWS_GetPlatformInfo -SCHost $SCHost

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $result"

    return $result
}

function GetAzStorageFileList()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting file list from storage account $OSAzStorageAccountName"

    # This function never throws anything
    $stoCtx = New-AzureStorageContext -StorageAccountName $OSAzStorageAccountName -SasToken $OSAzStorageSASToken -ErrorAction 'Stop'

    $ProgressPreference = "SilentlyContinue"
    $sources = $(Get-AzureStorageBlob -Container $OSAzStorageContainer -Context $stoCtx -ErrorAction 'Stop').Name

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($sources.Count)"

    return $sources
}
