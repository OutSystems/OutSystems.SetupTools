Function Stop-OSServices {
    <#
    .SYNOPSIS
    Stops Outsystems services.

    .DESCRIPTION
    This will stop all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        Try{
            CheckRunAsAdmin | Out-Null
        }
        Catch{
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    Process {
        ForEach ($OSService in $OSServices) {
            If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping OS service: $OSService"
                Get-Service -Name $OSService | Stop-Service -WarningAction SilentlyContinue
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service stopped"
            }
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}