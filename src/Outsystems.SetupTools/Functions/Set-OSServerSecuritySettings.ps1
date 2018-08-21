Function Set-OSServerSecuritySettings {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param()

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        try {
            CheckRunAsAdmin | Out-Null
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        if ($(-not $(GetServerVersion)) -or $(-not $(GetServerInstallDir))) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }
    }

    process {
        # Disable unsafe SSL protocols
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling unsafe SSL protocols"
        $Protocols = @("SSL 2.0", "SSL 3.0")
        try {
            foreach ($Protocol in $Protocols) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling $Protocol"
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server" -Force | Set-ItemProperty -Name "Enable" -Value 0
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Client" -Force | Set-ItemProperty -Name "DisabledByDefault" -Value 1
            }
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling unsafe SSL protocols"
            throw "Error disabling unsafe SSL protocols"
        }

        # Disable clickjacking (Server Level)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling click jacking"
        try {
            if (Get-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='X-Frame-Options']" -Name . ) {
                Set-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='X-Frame-Options']" -Name . -Value @{name = "X-Frame-Options"; value = "SAMEORIGIN"}
            }
            else {
                Add-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Name collection -Value @{name = "X-Frame-Options"; value = "SAMEORIGIN"}
            }

            if (Get-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='Content-Security-Policy']" -Name . ) {
                Set-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='Content-Security-Policy']" -Name . -Value @{name = "Content-Security-Policy"; value = "frame-ancestors 'self'"}
            }
            else {
                Add-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Name collection -Value @{name = "Content-Security-Policy"; value = "frame-ancestors 'self'"}
            }
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling click jacking"
            throw "Error disabling click jacking"
        }
    }

    end {
        Write-Output "Security settings successfully applied"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
