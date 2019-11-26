function Test-OSServerSoftwareReqs
{
    <#
    .SYNOPSIS
    Checks if the server has a supported operating system for OutSystems.

    .DESCRIPTION
    This will check if the server has a supported operating system to run the Outsystems platform.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    Accepted values: 10 or 11

    .EXAMPLE
    Test-OSServerSoftwareReqs -MajorVersion "10"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.TestResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0', '10', '11')]   # We changed the versioning of the product but we still support the old versioning
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Fix to support the old versioning
        $MajorVersion = $MajorVersion.Split('.')[0]

        # Initialize the results object
        $testResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.TestResult'
            Result     = $true
            Message    = "Operating system was validated for Outsystems $MajorVersion"
        }
    }

    process
    {
        if ($(GetOperatingSystemProductType) -lt $OSReqsMinOSProductType)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Operating system not supported. Only server editions are supported"
            WriteNonTerminalError -Message "Operating system not supported. Only server editions are supported"

            $testResult.Result = $false
            $testResult.Message = 'Operating system not supported. Only server editions are supported'

            return $testResult
        }

        switch ($MajorVersion)
        {
            '10'
            {
                if ([System.Version]$(GetOperatingSystemVersion) -lt [System.Version]$OS10ReqsMinOSVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "This operating system version is not supported for Outsystems $MajorVersion"
                    WriteNonTerminalError -Message "This operating system version is not supported for Outsystems $MajorVersion"

                    $testResult.Result = $false
                    $testResult.Message = "This operating system version is not supported for Outsystems $MajorVersion"

                    return $testResult
                }
            }
            '11'
            {
                if ([System.Version]$(GetOperatingSystemVersion) -lt [System.Version]$OS11ReqsMinOSVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "This operating system version is not supported for Outsystems $MajorVersion"
                    WriteNonTerminalError -Message "This operating system version is not supported for Outsystems $MajorVersion"

                    $testResult.Result = $false
                    $testResult.Message = "This operating system version is not supported for Outsystems $MajorVersion"

                    return $testResult
                }
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Operating system validated for Outsystems $MajorVersion"
        $testResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
