Function LogVerbose([string]$FuncName, [int]$Phase, [string]$Message){

    $Output = $((get-date).TimeOfDay.ToString())

    $Output += ' [' + $FuncName.PadRight(40) + ']'

    switch ($Phase) {
        0 { $Output += ' [BEGIN  ]' }
        1 { $Output += ' [PROCESS]' }
        2 { $Output += ' [END    ]' }
        3 { $Output += ' [ERROR  ]' }
    }

    $Output += ' ' + $Message

    Write-Verbose $Output

    If($script:LogFile -and ($script:LogFile -ne "")){
        Add-Content -Path $script:LogFile -Value "VERBOSE: $Output`n"
    }
}

Function LogDebug([string]$FuncName, [int]$Phase, [string]$Message){

    $Output = $((get-date).TimeOfDay.ToString())

    $Output += ' [' + $FuncName.PadRight(40) + ']'

    switch ($Phase) {
        0 { $Output += ' [BEGIN  ]' }
        1 { $Output += ' [PROCESS]' }
        2 { $Output += ' [END    ]' }
        3 { $Output += ' [ERROR  ]' }
    }

    $Output += ' ' + $Message

    Write-Debug $Output

    If($script:LogFile -and ($script:LogFile -ne "") -and ($script:LogDebug)){
        Add-Content -Path $script:LogFile -Value "DEBUG  : $Output`n"
    }
}

Function TestVerbose {
    [CmdletBinding()]
    param()
        [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
    }

Function InstallWindowsFeatures([string[]]$Features)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Install-WindowsFeature -Name $Features -Verbose:$false -ErrorAction Stop | Out-Null

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}

Function ConfigureServiceWindowsSearch()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    If ($(Get-Service -Name "WSearch" -ErrorAction SilentlyContinue)){

        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling the Windows search service."
        Set-Service -Name "WSearch" -StartupType "Disabled"

        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping the Windows search service."
        Get-Service -Name "WSearch" | Stop-Service

    } Else {
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service not found. Skipping."
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function DisableFIPS {

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting on registry HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled = 0"
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Force | Set-ItemProperty -Name "Enabled" -Value 0

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function ConfigureMSMQDomainServer {

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting on registry HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\AlwaysWithoutDS = 1"
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -Force | Set-ItemProperty -Name "AlwaysWithoutDS" -Value 1

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function CheckRunAsAdmin()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    If((New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Current user is admin."
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
        Return $true
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Current user is NOT admin!!."
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    Return $false

}

Function GetDotNet4Version()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the registry value HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\<langid>\Release."
    $DotNetVersion = $(Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction SilentlyContinue | Get-ItemProperty).Release
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Got value: $DotNetVersion"

    Return $DotNetVersion
}

Function GetNumberOfCores()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $NumOfCores = $WMIComputerSystem.NumberOfLogicalProcessors

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $NumOfCores"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $NumOfCores
}

Function GetInstalledRAM()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $InstalledRAM = $WMIComputerSystem.TotalPhysicalMemory
    $InstalledRAM = $InstalledRAM / 1GB

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $InstalledRAM GB"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $InstalledRAM
}

Function ConfigureServiceWMI()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Starting the WMI windows service and changing the startup type to automatic."
    Set-Service -Name "Winmgmt" -StartupType "Automatic" | Start-Service

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetOperatingSystemVersion()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSVersion = $WMIOperatingSystem.Version

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $OSVersion"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $OSVersion
}

Function GetOperatingSystemProductType()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSProductType = $WMIOperatingSystem.ProductType

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $OSProductType"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $OSProductType
}

Function ConfigureWindowsEventLog([string]$LogName, [string]$LogSize, [string]$LogOverflowAction)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting event log $LogName with maxsize of $LogSize and $LogOverflowAction"
    Limit-EventLog -MaximumSize $LogSize -OverflowAction $LogOverflowAction -LogName $LogName

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function RunConfigTool([string]$Arguments)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the file machine.config is locked before running the tool."
    $MachineConfigFile = "$ENV:windir\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"

    While(TestFileLock($MachineConfigFile)){
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File is locked!! Retrying is 10s."
        Start-Sleep -Seconds 10
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Running the config tool..."

    $Result = ExecuteCommand -CommandPath "$InstallDir\ConfigurationTool.com" -WorkingDirectory $InstallDir -CommandArguments "$Arguments"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $Result
}

Function InstallOSServiceCenter([string]$Path)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $InstallDir = GetServerInstallDir

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Running the OS Service Center installer...."

    #SCInstaller needs to run inside a CMD or will not return an exit code
    $Result = ExecuteCommand -CommandPath "$env:comspec" -WorkingDirectory $InstallDir -CommandArguments '/c SCInstaller.exe -file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif && exit /b %ERRORLEVEL%'

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "$($Result.Output)"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $Result
}

Function PublishSolution([string]$Solution, [string]$SCUser, [string]$SCPass)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $InstallDir = GetServerInstallDir

    $Version = [System.Version]$(GetServerVersion)
    $MajorVersion = "$($Version.Major).$($Version.Minor)"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server major version: $MajorVersion"

    $OSPToolPath = "$ENV:CommonProgramFiles\OutSystems\$MajorVersion"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTool path: $OSPToolPath"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Running the OSP tool..."
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Solution: $Solution"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the OSP tool will follow.....:"

    $Result = ExecuteCommand -CommandPath "$OSPToolPath\OSPTool.com" -WorkingDirectory $InstallDir -CommandArguments $("/publish " + [char]34 + $Solution + [char]34 + " $ENV:ComputerName $SCUser $SCPass")

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "$($Result.Output)"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the OSP end..................:"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    If( $Result.ExitCode -ne 0 ){
        throw "Error publishing the solution. Return code: $($Result.ExitCode)"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetServerInstallDir()
{

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\(Default)"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "(default)" -ErrorAction Stop)."(default)"
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output

    } catch {
        Throw "Outsystems platform is not installed"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetDevEnvInstallDir([string]$MajorVersion)
{

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\(default)"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "(default)" -ErrorAction Stop)."(default)"
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output -Replace "\Service Studio", ""

    } catch {
        Throw "Outsystems dev environment is not installed"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetServerVersion()
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Server"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Server"-ErrorAction Stop).Server
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output

    } catch {
        Throw "Outsystems platform is not installed"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetDevEnvVersion([string]$MajorVersion)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\Service Studio $MajorVersion"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "Service Studio $MajorVersion" -ErrorAction Stop)."Service Studio $MajorVersion"
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output

    } catch {
        Throw "Outsystems platform is not installed"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function DownloadOSSources([string]$URL, [string]$SavePath)
{
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Download sources from: $URL"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Save sources to: $SavePath"

    try{
        (New-Object System.Net.WebClient).DownloadFile($URL, $SavePath)
    } catch {
        Throw "Cannot download file from: $URL"
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File successfully downloaded!"

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function ExecuteCommand([string]$CommandPath, [string]$WorkingDirectory, [string]$CommandArguments)
{

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Launching the process $CommandPath with the arguments $CommandArguments"

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

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}

function TestFileLock([string]$Path)
{

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking if file $Path is locked"

    $File = New-Object System.IO.FileInfo $Path

    If ((Test-Path -Path $Path) -eq $false) {
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File does not exist. Returning false."
        Return $false
    }

    Try {
        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Openning"

        $Stream = $File.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        If ($Stream) {
            LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Sucessfully open the file. File is not locked"
            $Stream.Close()
            LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Closing and returnig false"
        }

        Return $false

    } Catch {

        LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File is locked!!! Returnig true!!"
        Return $true
    }

    LogDebug -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}