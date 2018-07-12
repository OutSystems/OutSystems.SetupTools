Function Start-OSServices {
    <#
    .SYNOPSIS
    Starts Outsystems services.

    .DESCRIPTION
    This will start all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Try{
            CheckRunAsAdmin | Out-Null
        }
        Catch{
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_ -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    Process {
        ForEach ($OSService in $OSServices) {
            If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting OS service: $OSService"
                Get-Service -Name $OSService | Where-Object {$_.StartType -ne "Disabled"} | Start-Service -WarningAction SilentlyContinue
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service started"
            }
        }
    }

    End {
        Write-Output "Outsystems services successfully started"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}