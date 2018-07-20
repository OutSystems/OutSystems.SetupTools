Function Disable-OSIPv6
{
    <#
    .SYNOPSIS
    Disable IPv6.

    .DESCRIPTION
    This will disable IPv6 on the server. IPv6 is not supported by Outsystems

    .EXAMPLE
    Disable-OSIPv6

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Try{
            CheckRunAsAdmin | Out-Null
        }
        Catch{
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    Process {
        Try{
            Get-NetAdapterBinding -ComponentID 'ms_tcpip6' | Disable-NetAdapterBinding -ComponentID ms_tcpip6
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value 0xffffffff -PropertyType "DWORD" -Force | Out-Null
        } Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling IPv6"
            Throw "Error disabling IPv6"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IPv6 successfully disabled"
    }

    End {
        Write-Output "IPv6 successfully disabled"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}