function Set-OSServerSecuritySettings
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    <#
    .SYNOPSIS
    Configures Windows and IIS with the recommended security settings for OutSystems.

    .DESCRIPTION
    This will configure Windows and IIS with the recommended security settings for the OutSystems platform.
    Will disable unsafe SSL protocols on Windows and add custom headers to protect IIS from click jacking.

    .EXAMPLE
    Set-OSServerSecuritySettings

    #>

    [CmdletBinding()]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        if ($(-not $(GetServerVersion)) -or $(-not $(GetServerInstallDir)))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return
        }

        # Disable unsafe SSL protocols
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling unsafe SSL protocols"
        $protocols = @("SSL 2.0", "SSL 3.0")
        try
        {
            foreach ($protocol in $protocols)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling $protocol"
                RegWrite -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server" -Name "Enabled" -Type "DWord" -Value 0
                RegWrite -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Client" -Name "Enabled" -Type "DWord" -Value 0
                RegWrite -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server" -Name "DisabledByDefault" -Type "DWord" -Value 1
                RegWrite -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Client" -Name "DisabledByDefault" -Type "DWord" -Value 1
            }
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling unsafe SSL protocols"
            WriteNonTerminalError -Message "Error disabling unsafe SSL protocols"

            return
        }

        # Disable clickjacking (Server Level)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling click jacking"
        try
        {
            SetWebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Value @{name = "X-Frame-Options"; value = "SAMEORIGIN"}
            SetWebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Value @{name = "Content-Security-Policy"; value = "frame-ancestors 'self'"}
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling click jacking"
            WriteNonTerminalError -Message "Error disabling click jacking"

            return
        }
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
