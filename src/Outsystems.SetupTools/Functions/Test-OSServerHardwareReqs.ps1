Function Test-OSServerHardwareReqs {
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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        #Configure the WMI windows service before running check. WMI is needed
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the WMI windows service"
        Try {
            ConfigureServiceWMI
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the WMI service"
            Throw "Error configuring the WMI service"
        }

        #CPU
        If ($(GetNumberOfCores) -lt $OSReqsMinCores) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported. Number of CPU cores is less than $OSReqsMinCores"
            Throw "Hardware not supported. Number of CPU cores is less than $OSReqsMinCores"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server has the necessary Number of cores for Outsystems"

        #MEM
        If ([int][Math]::Ceiling($(GetInstalledRAM)) -lt $OSReqsMinRAMGB) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported. Server has less than $OSReqsMinRAMGB GB"
            Throw "Hardware not supported. Server has less than $OSReqsMinRAMGB GB"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server has enought RAM"
    }

    End {
        Write-Output "Your server hardware was validated for Outsystems"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}