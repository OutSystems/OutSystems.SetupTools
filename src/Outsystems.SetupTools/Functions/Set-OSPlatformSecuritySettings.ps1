Function Set-OSPlatformSecuritySettings {
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
    Param()

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try {
            GetServerVersion | Out-Null
            GetServerInstallDir | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }

    }

    Process {
        # Disable unsafe SSL protocols
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling unsafe SSL protocols"
        $Protocols = @("SSL 2.0", "SSL 3.0")
        Try {
            ForEach ($Protocol in $Protocols) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling $Protocol"
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server" -Force | Set-ItemProperty -Name "Enable" -Value 0
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Client" -Force | Set-ItemProperty -Name "DisabledByDefault" -Value 1
            }
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling unsafe SSL protocols"
            Throw "Error disabling unsafe SSL protocols"
        }

        # Disable clickjacking (Server Level)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling click jacking"
        Try {
            If (Get-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='X-Frame-Options']" -Name . ) {
                Set-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='X-Frame-Options']" -Name . -Value @{name = "X-Frame-Options"; value = "SAMEORIGIN"}
            }
            Else {
                Add-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Name collection -Value @{name = "X-Frame-Options"; value = "SAMEORIGIN"}
            }

            If (Get-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='Content-Security-Policy']" -Name . ) {
                Set-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='Content-Security-Policy']" -Name . -Value @{name = "Content-Security-Policy"; value = "frame-ancestors 'self'"}
            }
            Else {
                Add-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site" -Filter "system.webServer/httpProtocol/customHeaders" -Name collection -Value @{name = "Content-Security-Policy"; value = "frame-ancestors 'self'"}
            }
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling click jacking"
            Throw "Error disabling click jacking"
        }
    }

    End {
        Write-Output "Security settings successfully applied"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}