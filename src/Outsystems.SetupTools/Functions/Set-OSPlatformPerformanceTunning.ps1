Function Set-OSPlatformPerformanceTunning
{
    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    # Process scheduling -- http://technet.microsoft.com/library/Cc976120
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting processor scheduling priority to background services"
    New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Force | Set-ItemProperty -Name "Win32PrioritySeparation" -Value 24

    # Configure .NET
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring .NET maxRequestLength and executionTimeout"
    Add-Type -AssemblyName System.Configuration #Needed for server 2K8R2
    $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET maxRequestLength to 131072"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = 131072
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET executionTimeout to 110 seconds"
    $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = [TimeSpan]::FromSeconds(110)

    $NETMachineConfig.Save()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}