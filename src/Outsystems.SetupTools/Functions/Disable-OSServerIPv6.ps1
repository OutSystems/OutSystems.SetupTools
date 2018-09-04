function Disable-OSServerIPv6
{
    <#
    .SYNOPSIS
    Disable IPv6.

    .DESCRIPTION
    This will disable IPv6 on the server.
    It will remove the IPv6 checkbox on all network interfaces and will also disable IPv6 globally.

    .EXAMPLE
    Disable-OSServerIPv6

    #>

    [CmdletBinding()]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        try
        {
            # https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
            Get-NetAdapterBinding -ComponentID 'ms_tcpip6' -ErrorAction SilentlyContinue | Disable-NetAdapterBinding -ComponentID ms_tcpip6 -ErrorAction Stop
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value 0xff -PropertyType "DWORD" -Force -ErrorAction Stop | Out-Null
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling IPv6"
            WriteNonTerminalError -Message "Error disabling IPv6"

            return
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IPv6 successfully disabled"
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
