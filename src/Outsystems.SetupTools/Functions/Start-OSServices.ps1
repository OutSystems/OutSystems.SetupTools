Function Start-OSServices
{
    <#
    .SYNOPSIS
    Starts Outsystems services.

    .DESCRIPTION
    This will start all Outsystems platform services by the recommended order.

    #>

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    If( -not $(CheckRunAsAdmin)) {Throw "The current user is not Administrator of the machine"}

    ForEach ($OSService in $OSServices) {
        If ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue)){
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Starting OS service: $OSService"
            Get-Service -Name $OSService | Where-Object {$_.StartType -ne "Disabled"} | Start-Service
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service started"
        }
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}