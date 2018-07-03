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
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        If ( -not $(CheckRunAsAdmin)) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator of the machine"
            Throw "The current user is not Administrator of the machine"
        }
    }

    Process {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Creating a windows firewall rule to allow inbound connections to TCP Port from 12000-12004"
        try {
            New-NetFirewallRule -DisplayName 'OutSystems' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('12000', '12001', '12002', '12003', '12004') | Out-Null
        }
        catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error creating the firewall rule"
            Throw "Error creating the firewall rule"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Firewall rule Outsystems created successfully"
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}