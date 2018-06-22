Function Test-OSPlatformHardwareReqs
{
    <#
    .SYNOPSIS
    Checks if the server has the necessary hardware requirements.

    .DESCRIPTION
    This will check if the server has the necessary hardware requirements to run the Outsystems platform. Checks available RAM and number of CPUs.
    Will throw an exception if the server does not meet the requirements.

    #>

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

     #Configure the WMI windows service
     Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the WMI windows service before checking the hardware"
     ConfigureServiceWMI
     Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "WMI service configured"

    #CPU
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking number of CPU cores"
    If($(GetNumberOfCores) -lt $OSReqsMinCores) { Throw "Hardware not supported. Number of CPU cores is less than $OSReqsMinCores" }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Number of cores supported for Outsystems"

    #MEM
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking installed RAM"
    If([int][Math]::Ceiling($(GetInstalledRAM)) -lt $OSReqsMinRAMGB) { Throw "Hardware not supported. Server has less than $OSReqsMinRAMGB GB" }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server has enought RAM"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}