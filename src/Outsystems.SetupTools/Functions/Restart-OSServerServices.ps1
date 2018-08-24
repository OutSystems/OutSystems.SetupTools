function Restart-OSServerServices {
    <#
    .SYNOPSIS
    Restarts Outsystems services.

    .DESCRIPTION
    This will restart all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        try
        {
            CheckRunAsAdmin | Out-Null
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    process
    {
        foreach ($OSService in $OSServices)
        {
            if ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue | Where-Object {$_.StartType -ne "Disabled"}))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Restarting OS service: $OSService"
                try
                {
                    Get-Service -Name $OSService | Restart-Service -WarningAction SilentlyContinue -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error restarting the service $OSService"
                    throw "Error restarting the service $OSService"
                }
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service restarted"
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
