function Test-OSServerHardwareReqs
{
    <#
    .SYNOPSIS
    Checks if the server has the necessary hardware requirements for the OutSystems platform server.

    .DESCRIPTION
    This will check if the server has the necessary hardware requirements to run the Outsystems platform. Checks available RAM and the number of available CPUs.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    Accepted values: 10.0 or 11.0

    .EXAMPLE
    Test-OSServerSoftwareReqs -MajorVersion "10.0"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.TestResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0')]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $testResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.TestResult'
            Result     = $true
            Message    = "Hardware was validated for Outsystems $MajorVersion"
        }
    }

    process
    {
        switch ($MajorVersion)
        {
            '10.0'
            {
                if ($(GetNumberOfCores) -lt $OS10ReqsMinCores)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS10ReqsMinCores"
                    WriteNonTerminalError -Message "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS10ReqsMinCores"

                    $testResult.Result = $false
                    $testResult.Message = "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS10ReqsMinCores"

                    return $testResult
                }

                if ([int][Math]::Ceiling($(GetInstalledRAM)) -lt $OS10ReqsMinRAMGB)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported. Server has less than $OS10ReqsMinRAMGB GB"
                    WriteNonTerminalError -Message "Hardware not supported for Outsystems $MajorVersion. Server has less than $OS10ReqsMinRAMGB GB"

                    $testResult.Result = $false
                    $testResult.Message = "Hardware not supported for Outsystems $MajorVersion. Server has less than $OS10ReqsMinRAMGB GB"

                    return $testResult
                }
            }
            '11.0'
            {
                if ($(GetNumberOfCores) -lt $OS11ReqsMinCores)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS11ReqsMinCores"
                    WriteNonTerminalError -Message "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS11ReqsMinCores"

                    $testResult.Result = $false
                    $testResult.Message = "Hardware not supported for Outsystems $MajorVersion. Number of CPU cores is less than $OS11ReqsMinCores"

                    return $testResult
                }

                if ([int][Math]::Ceiling($(GetInstalledRAM)) -lt $OS11ReqsMinRAMGB)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Hardware not supported. Server has less than $OS11ReqsMinRAMGB GB"
                    WriteNonTerminalError -Message "Hardware not supported for Outsystems $MajorVersion. Server has less than $OS11ReqsMinRAMGB GB"

                    $testResult.Result = $false
                    $testResult.Message = "Hardware not supported for Outsystems $MajorVersion. Server has less than $OS11ReqsMinRAMGB GB"

                    return $testResult
                }
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Hardware validated for Outsystems $MajorVersion"
        $testResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
