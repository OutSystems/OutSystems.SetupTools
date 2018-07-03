Function Disable-OSIPv6
{
    <#
    .SYNOPSIS
    Disable IPv6.

    .DESCRIPTION
    This will disable IPv6 on the server. IPv6 is not supported by Outsystems

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
        Try{
            Get-NetAdapterBinding -ComponentID 'ms_tcpip6' | Disable-NetAdapterBinding -ComponentID ms_tcpip6
            New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value 0xffffffff -PropertyType "DWORD" -Force | Out-Null
        } Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error disabling IPv6"
            Throw "Error disabling IPv6"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "IPv6 successfully disabled"
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}