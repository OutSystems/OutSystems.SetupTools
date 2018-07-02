Function Set-OSPlatformWindowsFirewall
{
    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Creating a windows firewall rule to allow inbound connections to TCP Port from 12000-12004"

    try {
        New-NetFirewallRule -DisplayName 'OutSystems' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('12000', '12001', '12002', '12003', '12004') | Out-Null
    }
    catch {
        Throw "Error creating the firewall rule"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Firewall rule Outsystems created successfully"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}