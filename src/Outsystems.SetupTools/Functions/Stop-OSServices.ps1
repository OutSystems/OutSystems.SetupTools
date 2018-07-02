Function Stop-OSServices
{
    <#
    .SYNOPSIS
    Stops Outsystems services.

    .DESCRIPTION
    This will stop all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    If( -not $(CheckRunAsAdmin)) {Throw "The current user is not Administrator of the machine"}

    ForEach ($OSService in $OSServices) {
        If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)){
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping OS service: $OSService"
            Get-Service -Name $OSService | Stop-Service -WarningAction SilentlyContinue
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service stopped"
        }
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}