Function Start-OSServices
{
    <#
    .SYNOPSIS
    Disable IPv6.

    .DESCRIPTION
    This will disable IPv6 on the server. IPv6 is not supported by Outsystems

    #>

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    If( -not $(CheckRunAsAdmin)) {Throw "The current user is not Administrator of the machine"}

    Try{
        Get-NetAdapterBinding -ComponentID 'ms_tcpip6' | Disable-NetAdapterBinding -ComponentID ms_tcpip6
        New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value 0xffffffff -PropertyType "DWORD"
    } Catch {
        Throw "Error disabling IPv6"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "IPv6 successfully disabled"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}