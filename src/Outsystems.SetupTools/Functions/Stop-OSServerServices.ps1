function Stop-OSServerServices
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]

    <#
    .SYNOPSIS
    Stops Outsystems services.

    .DESCRIPTION
    This will stop all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        foreach ($OSService in $OSServices)
        {
            if ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue | Where-Object {$_.StartType -ne "Disabled"}))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Stopping OS service: $OSService"
                try
                {
                    Get-Service -Name $OSService | Stop-Service -WarningAction SilentlyContinue -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error stopping the service $OSService"
                    WriteNonTerminalError -Message "Error stopping the service $OSService"

                    return
                }
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service stopped"
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service $OSService not found or is disabled. Skipping..."
            }
        }
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
