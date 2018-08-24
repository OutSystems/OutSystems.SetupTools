function Start-OSServerServices {
    <#
    .SYNOPSIS
    Starts Outsystems services.

    .DESCRIPTION
    This will start all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    param()

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        try{
            CheckRunAsAdmin | Out-Null
        }
        catch{
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    process {
        foreach ($OSService in $OSServices) {
            if ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting OS service: $OSService"
                Get-Service -Name $OSService | Where-Object {$_.StartType -ne "Disabled"} | Start-Service -WarningAction SilentlyContinue
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service started"
            }
        }
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
