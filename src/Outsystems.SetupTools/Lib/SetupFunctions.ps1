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
    $installResult =  Install-WindowsFeature -Name $Features -ErrorAction SilentlyContinue -Verbose:$false -WarningAction SilentlyContinue

    return $installResult
}

Function GetWindowsFeatureState([string]$Features)
{
    Return $($(Get-WindowsFeature -Name $Features -Verbose:$false).Installed)
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

function ConfigureServiceWMI()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the WMI windows service and changing the startup type to automatic."
    Set-Service -Name "Winmgmt" -StartupType "Automatic" -ErrorAction Stop | Start-Service -ErrorAction Stop
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

    try
    {
        $output = $(Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction Stop | Get-ItemProperty -ErrorAction Stop).Release
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function GetDotNetCoreVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost\Version"

    try
    {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost" -Name "Version" -ErrorAction Stop).Version
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    if (-not $output)
    {
        $output = '0.0.0.0'
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output
}

function InstallDotNet()
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\NDP471-KB4033342-x86-x64-AllOS-ENU.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLDotNET"
    DownloadOSSources -URL $OSRepoURLDotNET -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $Installer -ArgumentList "/q", "/norestart", "/MSIOPTIONS `"ALLUSERS=1 REBOOT=ReallySuppress`"" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returning $($result.ExitCode)"

    return $($result.ExitCode)
}

function SetDotNetLimits([int]$UploadLimit, [TimeSpan]$ExecutionTimeout)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Openning the config file"
    $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting .NET maximum request size (maxRequestLength = 131072)"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = $UploadLimit

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Setting .NET execution timeout (executionTimeout = 110 seconds)"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = $ExecutionTimeout

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Saving config"
    $NETMachineConfig.Save()
}

function InstallBuildTools()
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\BuildTools_Full.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLBuildTools"
    DownloadOSSources -URL $OSRepoURLBuildTools -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $Installer -ArgumentList "-quiet" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returnig $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallDotNetCore()
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\DotNetCore_2_WindowsHosting.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLDotNETCore"
    DownloadOSSources -URL $OSRepoURLDotNETCore -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $Installer -ArgumentList "/install", "/quiet", "/norestart" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returnig $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallErlang([string]$InstallDir)
{
    $installer = "$ENV:TEMP\otp_win64.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLErlang"
    DownloadOSSources -URL $OSRepoURLErlang -SavePath $installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $result = Start-Process -FilePath $installer -ArgumentList "/S", "/D=$InstallDir" -Wait -PassThru -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returnig $($result.ExitCode)"

    return $($result.ExitCode)
}

function InstallRabbitMQ([string]$InstallDir)
{
    $installer = "$ENV:TEMP\rabbitmq-server-3.7.4.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLRabbitMQ"
    DownloadOSSources -URL $OSRepoURLRabbitMQ -SavePath $installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"

    # This needed to be like this because the rabbit installer is buggy and hangs the Start-Process!!
    $proc = Start-Process -FilePath $installer -ArgumentList "/S", "/D=$InstallDir" -Wait:$false -PassThru -ErrorAction Stop
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
}

function RabbitMQAddVirtualHost([string]$VirtualHost)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Adding virtual host $VirtualHost to RabbitMQ"

    $uri = "$OSRabbitMQDefaultURI/api/vhosts/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))"

    # This throws a statement terminating error. Try/catch it
    Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -Method Put -ContentType "application/json" -AllowEscapedDotsAndSlashes -Verbose:$false | Out-Null
}

function RabbitMQAddAdminUser([System.Management.Automation.PSCredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Adding admin user $($Credential.Username) to RabbitMQ"

    $uri = "$OSRabbitMQDefaultURI/api/users/$([System.Web.HttpUtility]::UrlEncode($($Credential.Username)))"
    $body = @{
        'username' = $Credential.Username
        'password' = $Credential.GetNetworkCredential().Password
        'tags' = 'administrator'
    } | ConvertTo-Json

    # This throws a statement terminating error. Try/catch it
    Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -Method Put -ContentType "application/json" -Body $body -AllowEscapedDotsAndSlashes -Verbose:$false | Out-Null
}

function RabbitMQAddAPermisionToAllVirtualHosts([string]$User)
{
    # Get all virtual hosts
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting all virtual hosts"

    $uri = "$OSRabbitMQDefaultURI/api/vhosts"

    # Needs to be in a try/catch block or will continue the execution
    try
    {
        $apiResponse = Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -Method Get -ContentType "application/json" -AllowEscapedDotsAndSlashes -Verbose:$false
    }
    catch
    {
        throw $_
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "We found $($apiResponse.name.Count) virtual hosts"

    # Set full permissions on all vhosts to the user
    foreach ($virtualHost in $apiResponse.name)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Adding full permission to user $User on virtual host $virtualHost"
        $uri = "$OSRabbitMQDefaultURI/api/permissions/$([System.Web.HttpUtility]::UrlEncode($virtualHost))/$([System.Web.HttpUtility]::UrlEncode($User))"
        $body = @{
                'configure' = '.*'
                'read' = '.*'
                'write' = '.*'
        } | ConvertTo-Json -ErrorAction Stop

        # Needs to be in a try/catch block or will continue the execution
        try
        {
            Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -Method Put -ContentType "application/json" -Body $body -AllowEscapedDotsAndSlashes -Verbose:$false | Out-Null
        }
        catch
        {
            throw $_
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Finished configuring virtual host permissions"
    }
}

function RabbitMQRemoveGuestUser()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Removing the guest user"
    $uri = "$OSRabbitMQDefaultURI/api/users/guest"

    # This throws a statement terminating error. Try/catch it
    Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -Method Delete -ContentType "application/json" -AllowEscapedDotsAndSlashes -Verbose:$false | Out-Null
}

function isRabbitMQAvailable()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking if RabbitMQ server in $OSRabbitMQDefaultURI is available"

    $uri = "$OSRabbitMQDefaultURI/api/overview"

    try
    {
         # This throws a statement terminating error. Try/catch it
        Invoke-RestMethod -Uri $uri -Credential $OSRabbitMQDefaultCredentials -AllowEscapedDotsAndSlashes -Verbose:$false | Out-Null
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "RabbitMQ $OSRabbitMQDefaultURI server is NOT available"
        return $false
    }
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Server is now available"

    return $true
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

Function RunConfigTool([string]$Arguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Check if the file machine.config is locked before running the tool."
    $MachineConfigFile = "$ENV:windir\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"

    While(TestFileLock($MachineConfigFile)){
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File is locked!! Retrying is 10s."
        Start-Sleep -Seconds 10
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running the config tool..."
    $Result = ExecuteCommand -CommandPath "$InstallDir\ConfigurationTool.com" -WorkingDirectory $InstallDir -CommandArguments "$Arguments"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($Result.ExitCode)"

    Return $Result
}

function RunSCInstaller([string]$Arguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $installDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running SCInstaller..."
    #SCInstaller needs to run inside a CMD or will not return an exit code
    $result = ExecuteCommand -CommandPath "$env:comspec" -WorkingDirectory $installDir -CommandArguments "/c SCInstaller.exe $Arguments && exit /b %ERRORLEVEL%" -ErrorAction Stop

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($result.ExitCode)"

    return $result
}

function PublishSolution([string]$Solution, [string]$SCUser, [string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Solution path: $Solution"
    $result = RunOSPTool -Arguments $("/publish " + [char]34 + $("$Solution") + [char]34 + " $ENV:ComputerName $SCUser $SCPass")

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Exit code: $($result.ExitCode)"

    return $result
}

function RunOSPTool([string]$Arguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $installDir = GetServerInstallDir

    $version = [System.Version]$(GetServerVersion)
    $majorVersion = "$($version.Major).$($version.Minor)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Server major version is $majorVersion"

    $ospToolPath = "$ENV:CommonProgramFiles\OutSystems\$majorVersion"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "OSPTool path is $ospToolPath"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running the OSPTool..."
    $result = ExecuteCommand -CommandPath "$ospToolPath\OSPTool.com" -WorkingDirectory $installDir -CommandArgument $Arguments

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

function GetServiceStudioInstallDir([string]$MajorVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\(default)"
    $output = RegRead -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "(default)"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"

    return $output -Replace "\Service Studio", ""
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

Function ExecuteCommand([string]$CommandPath, [string]$WorkingDirectory, [string]$CommandArguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Launching the process $CommandPath with the arguments $CommandArguments"

    Try {
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
        $Output = $Process.StandardOutput.ReadToEnd()

        $Process.WaitForExit()

        Return [PSCustomObject]@{
            Output = $Output
            ExitCode = $Process.ExitCode
        }
    }
    Catch {
        Throw "Error launching the process $CommandPath $CommandArguments"
    }

}

Function TestFileLock([string]$Path)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking if file $Path is locked"

    $File = New-Object System.IO.FileInfo $Path

    If ((Test-Path -Path $Path) -eq $false) {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File does not exist. Returning false."
        Return $false
    }

    Try {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Openning"

        $Stream = $File.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        If ($Stream) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Sucessfully open the file. File is not locked"
            $Stream.Close()
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Closing and returnig false"
        }

        Return $false

    } Catch {

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File is locked!!! Returnig true!!"
        Return $true
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
