function Set-OSServerWindowsFirewall
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]

    <#
    .SYNOPSIS
    Creates windows firewall rule for Outsystems services.

    .DESCRIPTION
    This will create a firewall rule named Outsystems and will opens the TCP Ports 12000, 12001, 12002, 12003, 12004 in all firewall profiles.

    .PARAMETER IncludeRabbitMQ
    If set to true it will open the TCP Port 5672 needed for rabbitMQ. Defaults to false.

    .EXAMPLE
    Set-OSServerWindowsFirewall -IncludeRabbitMQ:$false

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [bool]$IncludeRabbitMQ = $false
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        $tcpPorts = @('12000', '12001', '12002', '12003', '12004')
        if ($IncludeRabbitMQ)
        {
            $tcpPorts += '5672'
        }
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating Outsystems windows firewall rule"

        try
        {
            New-NetFirewallRule -DisplayName 'OutSystems' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort $tcpPorts -ErrorAction Stop | Out-Null
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the firewall rule"
            WriteNonTerminalError -Message "Error creating the firewall rule"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Firewall rule Outsystems created successfully"
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
