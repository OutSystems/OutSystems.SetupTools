function Write-OSInstallLog
{
    <#
    .SYNOPSIS
    Writes a message on the log file and on the verbose stream.

    .DESCRIPTION
    This will Write a message on the log file and on the verbose stream.

    .PARAMETER LogDebug
    Writes on the log the debug stream

    .EXAMPLE
    Write-OSInstallLog -Message 'My Message'

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    begin
    {
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $Message
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
    }
}
