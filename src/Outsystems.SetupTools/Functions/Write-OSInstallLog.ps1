function Write-OSInstallLog
{
    <#
    .SYNOPSIS
    Writes a message on the log file and on the verbose stream.

    .DESCRIPTION
    This will Write a message on the log file and on the verbose stream.

    .PARAMETER Name
    The name on the log. Defaults to the function name if not specified.

    .PARAMETER Message
    Message to write on the log

    .EXAMPLE
    Write-OSInstallLog -Message 'My Message'

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name = $($MyInvocation.Mycommand),

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
        LogMessage -Function $Name -Phase 1 -Stream 0 -Message $Message
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
    }
}
