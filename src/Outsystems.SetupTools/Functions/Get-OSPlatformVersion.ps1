function Get-OSPlatformVersion
{
    <#
    .SYNOPSIS
    Returns the platform version.

    .DESCRIPTION
    This will return the OutSystems platform version from the Service Center API.

    .PARAMETER ServiceCenterHost
    Service Center address. If not specified, will default to localhost (127.0.0.1).

    .EXAMPLE
    $Credential = Get-Credential
    Get-OSPlatformModules -ServiceCenterHost "10.0.0.1" -Credential $Credential

    .EXAMPLE
    Using the pipeline
    $Credential = Get-Credential
    @(@{'ServiceCenterHost'="10.0.0.1";'Credential'=$Credential},@{'ServiceCenterHost'="10.0.0.3";'Credential'=$Credential}) | Get-OSPlatformVersion

    #>

    [CmdletBinding()]
    [OutputType('System.Version')]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Alias('Host')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ServiceCenterHost = '127.0.0.1',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred
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
            $version = GetPlatformVersion -SCHost $ServiceCenterHost -Credential $Credential
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
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
