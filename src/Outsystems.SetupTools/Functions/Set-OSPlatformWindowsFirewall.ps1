Function Set-OSPlatformWindowsFirewall {
    <#
    .SYNOPSIS
    Creates windows firewall rule for Outsystems services.

    .DESCRIPTION
    This will create a firewall rule named Outsystems and will opens the TCP Ports 12000, 12001, 12002, 12003, 12004 in all firewall profiles.

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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating a windows firewall rule to allow inbound connections to TCP Port from 12000-12004"
        Try {
            New-NetFirewallRule -DisplayName 'OutSystems' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('12000', '12001', '12002', '12003', '12004') | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the firewall rule"
            Throw "Error creating the firewall rule"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Firewall rule Outsystems created successfully"
    }

    End {
        Write-Output "Windows firewall successfully configured for Outsystems"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}