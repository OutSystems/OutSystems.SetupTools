Function Test-OSPlatformHardwareReqs {
    <#
    .SYNOPSIS
    Checks if the server has the necessary hardware requirements.

    .DESCRIPTION
    This will check if the server has the necessary hardware requirements to run the Outsystems platform. Checks available RAM and number of CPUs.
    Will throw an exception if the server does not meet the requirements.

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        #Configure the WMI windows service
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the WMI windows service before checking the hardware"
        ConfigureServiceWMI

        #CPU
        If ($(GetNumberOfCores) -lt $OSReqsMinCores) {
            Throw "Hardware not supported. Number of CPU cores is less than $OSReqsMinCores"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Hardware not supported. Number of CPU cores is less than $OSReqsMinCores"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server has the necessary Number of cores for Outsystems"

        #MEM
        If ([int][Math]::Ceiling($(GetInstalledRAM)) -lt $OSReqsMinRAMGB) {
            Throw "Hardware not supported. Server has less than $OSReqsMinRAMGB GB"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Hardware not supported. Server has less than $OSReqsMinRAMGB GB"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server has enought RAM"
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}