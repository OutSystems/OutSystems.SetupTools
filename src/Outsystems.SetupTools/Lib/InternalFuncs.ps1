Function Write-MyVerbose([string]$FuncName, [int]$Phase, [string]$Message){

    $Output = $((get-date).TimeOfDay.ToString())

    $Output += ' [' + $FuncName.PadRight(40) + ']'

    switch ($Phase) {
        0 { $Output += ' [BEGIN  ]' }
        1 { $Output += ' [PROCESS]' }
        2 { $Output += ' [END    ]' }
    }

    $Output += ' ' + $Message

    Write-Verbose $Output
}

Function TestVerbose {
    [CmdletBinding()]
    param()
        [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
    }

Function InstallWindowsFeatures([string[]]$Features)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Features list:"
    ForEach ($Feature in $Features) { Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message $Feature }

    Install-WindowsFeature -Name $Features -Verbose:$false -ErrorAction Stop | Out-Null

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}

Function ConfigureServiceWindowsSearch()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    If ($(Get-Service -Name "WSearch" -ErrorAction SilentlyContinue)){

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling the Windows search service."
        Set-Service -Name "WSearch" -StartupType "Disabled"

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping the Windows search service."
        Get-Service -Name "WSearch" | Stop-Service

    } Else {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service not found. Skipping."
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function DisableFIPS {

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting on registry HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled = 0"
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Force | Set-ItemProperty -Name "Enabled" -Value 0

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function ConfigureMSMQDomainServer {

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting on registry HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\AlwaysWithoutDS = 1"
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup" -Force | Set-ItemProperty -Name "AlwaysWithoutDS" -Value 1

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function CheckRunAsAdmin()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    If((New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Current user is admin."
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
        Return $true
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Current user is NOT admin!!."
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    Return $false

}

Function GetDotNet4Version()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the registry value HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\<langid>\Release."
    $DotNetVersion = $(Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction SilentlyContinue | Get-ItemProperty).Release
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Got value: $DotNetVersion"

    Return $DotNetVersion
}

Function GetNumberOfCores()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $NumOfCores = $WMIComputerSystem.NumberOfLogicalProcessors

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $NumOfCores"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $NumOfCores
}

Function GetInstalledRAM()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $InstalledRAM = $WMIComputerSystem.TotalPhysicalMemory
    $InstalledRAM = $InstalledRAM / 1GB

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $InstalledRAM GB"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $InstalledRAM
}

Function ConfigureServiceWMI()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Starting the WMI windows service and changing the startup type to automatic."
    Set-Service -Name "Winmgmt" -StartupType "Automatic" | Start-Service

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetOperatingSystemVersion()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSVersion = $WMIOperatingSystem.Version

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $OSVersion"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $OSVersion
}

Function GetOperatingSystemProductType()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $WMIOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $OSProductType = $WMIOperatingSystem.ProductType

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $OSProductType"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $OSProductType
}

Function ConfigureWindowsEventLog([string]$LogName, [string]$LogSize, [string]$LogOverflowAction)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting event log $LogName with maxsize of $LogSize and $LogOverflowAction"
    Limit-EventLog -MaximumSize $LogSize -OverflowAction $LogOverflowAction -LogName $LogName

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function RunConfigTool([string]$Arguments)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting server install directory"
    $InstallDir = GetServerInstallDir

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Running the config tool..."
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the configuration tool will follow.....:"
    If(TestVerbose) {
        $Result = Start-Process -FilePath "$InstallDir\ConfigurationTool.com" -WorkingDirectory $InstallDir -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    } Else {
        $Result = Start-Process -FilePath "$InstallDir\ConfigurationTool.com" -WorkingDirectory $InstallDir -ArgumentList $Arguments -Wait -PassThru -NoNewWindow | Out-Null
    }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the configuration end..................:"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    If( $Result.ExitCode -ne 0 ){
        throw "Error configuring the platform. Return code: $($Result.ExitCode)"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function InstallOSSystemCenter([string]$Path)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $InstallDir = GetServerInstallDir

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing OS Service Center"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the tool will follow .........:"

    If(TestVerbose) {
        $Result = Start-Process -FilePath "$InstallDir\SCInstaller.exe" -WorkingDirectory $InstallDir -ArgumentList "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif" -Wait -PassThru -NoNewWindow -LoadUserProfile
    } Else {
        $Result = Start-Process -FilePath "$InstallDir\SCInstaller.exe" -WorkingDirectory $InstallDir -ArgumentList "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif" -Wait -PassThru -NoNewWindow -LoadUserProfile | Out-Null
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the tool end .................:"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    If( $Result.ExitCode -ne 0 ){
        throw "Error installing service center. Return code: $($Result.ExitCode)"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function PublishSolution([string]$Solution, [string]$SCUser, [string]$SCPass)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $Version = [System.Version]$(GetServerVersion)
    $MajorVersion = "$($Version.Major).$($Version.Minor)"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server major version: $MajorVersion"

    $OSPToolPath = "$ENV:CommonProgramFiles\OutSystems\$MajorVersion"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTool path: $OSPToolPath"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Running the OSP tool..."
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Solution: $Solution"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the OSP tool will follow.....:"
    If(TestVerbose) {
        $Result = Start-Process -FilePath "$OSPToolPath\OSPTool.com" -WorkingDirectory $OSPToolPath  `
        -ArgumentList $("/publish " + [char]34 + $Solution + [char]34), "$ENV:ComputerName $SCUser $SCPass" -Wait -PassThru -NoNewWindow
    } Else {
        $Result = Start-Process -FilePath "$OSPToolPath\OSPTool.com" -WorkingDirectory $OSPToolPath  `
        -ArgumentList $("/publish " + [char]34 + $Solution + [char]34), "$ENV:ComputerName $SCUser $SCPass" -Wait -PassThru -NoNewWindow | Out-Null
    }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Output of the OSP end..................:"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Return code: $($Result.ExitCode)"

    If( $Result.ExitCode -ne 0 ){
        throw "Error publishing the solution. Return code: $($Result.ExitCode)"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetServerInstallDir()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\(Default)"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "(default)" -ErrorAction Stop)."(default)"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output

    } catch {
        Throw "Outsystems platform is not installed"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function GetServerVersion()
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Server\Server"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Server" -Name "Server"-ErrorAction Stop).Server
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

        return $output

    } catch {
        Throw "Outsystems platform is not installed"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}

Function DownloadOSSources([string]$URL, [string]$SavePath)
{
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Download sources from: $URL"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Save sources to: $SavePath"

    try{
        (New-Object System.Net.WebClient).DownloadFile($URL, $SavePath)
    } catch {
        Throw "Cannot download file from: $URL"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File successfully downloaded!"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}