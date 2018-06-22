Function Install-OSPlatformServerPreReqs
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InstallMSMQ
    Parameter description

    .PARAMETER InstallIISMgmtConsole
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [bool]$InstallMSMQ=$true,
        [bool]$InstallIISMgmtConsole=$true
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights."
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console." }

    #Install required windows features
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing windows features"
    $WinFeatures = $OSWindowsFeaturesBase
    If($InstallMSMQ) {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Adding MSMQ to the list."
        $WinFeatures += "MSMQ"
    }

    If($InstallIISMgmtConsole) {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Adding IIS Management console to the list."
        $WinFeatures += "Web-Mgmt-Console"
    }

    #Do the actual install
    InstallWindowsFeatures -Features $WinFeatures

    #Configure the WMI windows service
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the WMI windows service before checking the hardware."
    ConfigureServiceWMI

    #Stop and disable windows search service
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping and disabling the Windows search service."
    ConfigureServiceWindowsSearch

    #Disable FIPS compliant algorithms checks
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling FIPS compliant algorithms checks."
    DisableFIPS

    #Configure MSMQ
    If($InstallMSMQ) {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configure Message Queuing service to to always try to contact a message queue server when running on a server registered in a domain."
        ConfigureMSMQDomainServer
    }

    #Configure event log
    ForEach ($EventLog in $OSWinEventLogName){
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring Windows Event Log: $EventLog"
        ConfigureWindowsEventLog -LogName $EventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}