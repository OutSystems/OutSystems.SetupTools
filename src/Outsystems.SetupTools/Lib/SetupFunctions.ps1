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
    $currentProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    $installResult =  Install-WindowsFeature -Name $Features -ErrorAction Stop -Verbose:$false -WarningAction SilentlyContinue
    $ProgressPreference = $currentProgressPreference
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
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -ErrorAction Ignore
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Name "Enabled" -Value 0 -ErrorAction Stop
}

function ConfigureMSMQDomainServer
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\AlwaysWithoutDS = 1"
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -ErrorAction Ignore
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -Name "AlwaysWithoutDS" -Value 1 -ErrorAction Stop
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
    $intReturnCode = Start-Process -FilePath $Installer -ArgumentList "/q", "/norestart", "/MSIOPTIONS `"ALLUSERS=1 REBOOT=ReallySuppress`"" -Wait -PassThru -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished. Returning $($intReturnCode.ExitCode)"

    return $($intReturnCode.ExitCode)
}

function InstallBuildTools()
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\BuildTools_Full.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLBuildTools"
    DownloadOSSources -URL $OSRepoURLBuildTools -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $intReturnCode = Start-Process -FilePath $Installer -ArgumentList "-quiet" -Wait -PassThru -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished"

    return $($intReturnCode.ExitCode)
}

function InstallDotNetCore()
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\DotNetCore_2_WindowsHosting.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLDotNETCore"
    DownloadOSSources -URL $OSRepoURLDotNETCore -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $intReturnCode = Start-Process -FilePath $Installer -ArgumentList "/install", "/quiet", "/norestart" -Wait -PassThru -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished"

    return $($intReturnCode.ExitCode)
}

function InstallErlang([string]$InstallDir)
{
    #Download sources from repo
    $Installer = "$ENV:TEMP\otp_win64.exe"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Downloading sources from: $OSRepoURLErlang"
    DownloadOSSources -URL $OSRepoURLErlang -SavePath $Installer

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Starting the installation"
    $intReturnCode = Start-Process -FilePath $Installer -ArgumentList "/S", "/D=$InstallDir" -Wait -PassThru -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Installation finished"

    return $($intReturnCode.ExitCode)
}

function IsMSIInstalled([string]$ProductCode)
{
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
    if ($Products -match $ProductCode){
        return $true
    }
    else
    {
        return $false
    }
}

Function GetNumberOfCores()
{
    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $NumOfCores = $WMIComputerSystem.NumberOfLogicalProcessors

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $NumOfCores"

    Return $NumOfCores
}

Function GetInstalledRAM()
{
    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $InstalledRAM = $WMIComputerSystem.TotalPhysicalMemory
    $InstalledRAM = $InstalledRAM / 1GB

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $InstalledRAM GB"

    Return $InstalledRAM
}

Function GetOperatingSystemVersion()
{
    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSVersion = $WMIOperatingSystem.Version

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $OSVersion"

    Return $OSVersion
}

Function GetOperatingSystemProductType()
{
    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSProductType = $WMIOperatingSystem.ProductType

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $OSProductType"

    Return $OSProductType
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
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Return code: $($Result.ExitCode)"

    Return $Result
}

Function RunSCInstaller([string]$Arguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running SCInstaller..."
    #SCInstaller needs to run inside a CMD or will not return an exit code
    $Result = ExecuteCommand -CommandPath "$env:comspec" -WorkingDirectory $InstallDir -CommandArguments "/c SCInstaller.exe $Arguments && exit /b %ERRORLEVEL%"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Return code: $($Result.ExitCode)"

    Return $Result
}

Function PublishSolution([string]$Solution, [string]$SCUser, [string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Solution path: $Solution"
    $Result = RunOSPTool -Arguments $("/publish " + [char]34 + $("$Solution") + [char]34 + " $ENV:ComputerName $SCUser $SCPass")
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Return code: $($Result.ExitCode)"

    Return $Result
}

Function RunOSPTool([string]$Arguments)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    $Version = [System.Version]$(GetServerVersion)
    $MajorVersion = "$($Version.Major).$($Version.Minor)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Server major version is $MajorVersion"

    $OSPToolPath = "$ENV:CommonProgramFiles\OutSystems\$MajorVersion"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "OSPTool path is $OSPToolPath"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Running the OSPTool..."
    $Result = ExecuteCommand -CommandPath "$OSPToolPath\OSPTool.com" -WorkingDirectory $InstallDir -CommandArgument $Arguments
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Return code: $($Result.ExitCode)"

    Return $Result
}

function GetServerInstallDir()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\(Default)"

    try
    {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "(default)" -ErrorAction Stop)."(default)"
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"
    return $output
}

function GetServiceStudioInstallDir([string]$MajorVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\(default)"

    try
    {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "(default)" -ErrorAction Stop)."(default)"
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $output"
    return $output -Replace "\Service Studio", ""
}

function GetServerVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Server"

    try
    {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Server" -ErrorAction Stop).Server
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"
    return $output
}

function GetServiceStudioVersion([string]$MajorVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\Service Studio $MajorVersion"

    try
    {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "Service Studio $MajorVersion" -ErrorAction Stop)."Service Studio $MajorVersion"
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"
    return $output
}

function DownloadOSSources([string]$URL, [string]$SavePath)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Download sources from $URL"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Save sources to $SavePath"

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

function TestFileLock([string]$Path)
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

Function GetSCCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\ServiceCenter"

    try {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "ServiceCenter" -ErrorAction SilentlyContinue).ServiceCenter
    } catch {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error getting the service center version"
        throw "Error getting the service center version"
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"
    return $output
}

Function SetSCCompiledVersion([string]$SCVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\ServiceCenter = $SCVersion"
    New-Item -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -ErrorAction Ignore
    Set-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "ServiceCenter" -Value "$SCVersion"
}

Function GetSysComponentsCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\SystemComponents"

    try {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "SystemComponents" -ErrorAction SilentlyContinue).SystemComponents
    } catch {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error getting the system components version"
        throw "Error getting the system components version"
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"
    return $output
}

Function SetSysComponentsCompiledVersion([string]$SysComponentsVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\SystemComponents = $SysComponentsVersion"
    New-Item -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -ErrorAction Ignore
    Set-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "SystemComponents" -Value "$SysComponentsVersion"
}

Function GetLifetimeCompiledVersion()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Lifetime"

    try {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Lifetime" -ErrorAction SilentlyContinue).Lifetime
    } catch {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error getting the lifetime version"
        throw "Error getting the lifetime version"
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning: $output"
    return $output
}

Function SetLifetimeCompiledVersion([string]$LifetimeVersion)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting on registry HKLM:SOFTWARE\OutSystems\Installer\Server\Lifetime = $LifetimeVersion"
    New-Item -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -ErrorAction Ignore
    Set-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Lifetime" -Value "$LifetimeVersion"
}

function GenerateEncryptKey()
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Generating a new encrypted key"
    $Key = [OutSystems.HubEdition.RuntimePlatform.NewRuntime.Authentication.Keys]::GenerateEncryptKey()
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returnig $Key"

    return $Key
}
