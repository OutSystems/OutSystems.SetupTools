Function Restart-OSServices {
    <#
    .SYNOPSIS
    Restarts Outsystems services.

    .DESCRIPTION
    This will restart all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        If ( -not $(CheckRunAsAdmin)) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator of the machine"
            Throw "The current user is not Administrator of the machine"
        }
    }

    Process {
        ForEach ($OSService in $OSServices) {
            If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Restarting OS service: $OSService"
                Get-Service -Name $OSService | Where-Object {$_.StartType -ne "Disabled"} | Restart-Service -WarningAction SilentlyContinue
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service restarted"
            }
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}