function Get-OSPlatformVersion
{
    <#
    .SYNOPSIS
    Gets the platform version from Service Center.

    .DESCRIPTION
    This will return the Outsystems platform version from Service Center API.

    .PARAMETER Host
    Service Center address. If not specified, will default to localhost (127.0.0.1).

    .EXAMPLE
    Get-OSPlatformVersion -ServiceCenterHost "10.0.0.1"

    Using the pipeline
    "10.0.0.1", "10.0.0.1", "10.0.0.3" | Get-OSPlatformVersion

    #>

    [CmdletBinding()]
    [OutputType('System.Version')]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Alias('Host')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ServiceCenterHost = '127.0.0.1'
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        try
        {
            $refDummy = ""
            $version = $(GetOutSystemsPlatformWS -SCHost $ServiceCenterHost).GetPlatformInfo(([ref]$refDummy))
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error contacting service center or getting the platform version"
            WriteNonTerminalError -Message "Error contacting service center or getting the platform version"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $version"
        return [System.version]$version
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
