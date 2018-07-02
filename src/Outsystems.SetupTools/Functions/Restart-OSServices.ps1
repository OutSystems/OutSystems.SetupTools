Function Restart-OSServices
{
    <#
    .SYNOPSIS
    Restarts Outsystems services.

    .DESCRIPTION
    This will restart all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    If( -not $(CheckRunAsAdmin)) {Throw "The current user is not Administrator of the machine"}

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    ForEach ($OSService in $OSServices) {
        If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)){
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Restarting OS service: $OSService"
            Get-Service -Name $OSService | Where-Object {$_.StartType -ne "Disabled"} | Restart-Service -WarningAction SilentlyContinue
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service restarted"
        }
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}