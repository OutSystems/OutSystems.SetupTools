function Set-OSServerWindowsFirewall
{
    <#
    .SYNOPSIS
    Creates rules in the Windows Firewall to allow communication to the default ports of the OutSystems services.

    .DESCRIPTION
    This will create rules in the Windows Firewall to allow communication to the default ports of the OutSystems services,
    depending on the major version of the OutSystems platform specified.
    It also allows to restrict communication to source IPs the local subnet and to choose to which firewall profiles the rule applies to.

    .PARAMETER OSServerRoles
    The OutSystems platform roles the server as, to determine which services will be running and what rules to enable.

    .PARAMETER MajorVersion
    The major version of the OutSystems platform used in the server, to determine which services will be running.

    .PARAMETER IncludeCacheInvalidation
    If specified, it will enable the rule to allow communication to the default port ofthe cache invalication service (RabbitMQ).

    .PARAMETER RestrictLocalSubnet
    If specified, the firewall rule will include a restriction to only allow traffic with a source IP in the local subnet.

    .PARAMETER FWProfiles
    The firewall profiles that the rule will apply to.

    .EXAMPLE
    Set-OSServerWindowsFirewall -MajorVersion 11 -OSServerRoles DC,FE -IncludeCacheInvalidation -RestrictLocalSubnet -FWProfiles Private

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('DC', 'FE')]
        [array]$OSServerRoles = @('DC','FE'),

        [Parameter()]
        [ValidateSet('10', '11')]
        [string]$MajorVersion = '11',

        [Parameter()]
        [Alias('IncludeRabbitMQ')]
        [switch]$IncludeCacheInvalidation,

        [Parameter()]
        [switch]$RestrictLocalSubnet,

        [Parameter()]
        [ValidateSet('Public', 'Private', 'Domain')]
        [array]$FWProfiles
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }
    }

    process
    {

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating firewall rules for OutSystems services"

        ### Set common parameters of the firewall rules
        $FWRuleParams = @{
            Direction = 'Inbound'
            Protocol = 'TCP'
            Action = 'Allow'
            Group = 'OutSystems'
            Enabled = 'False'
        }

        if ($null -ne $FWProfiles) {
            $FWRuleParams.Add("Profile", $FWProfiles )
        }

        if ($RestrictLocalSubnet -eq $true) {
            $FWRuleParams.Add('RemoteAddress', 'LocalSubnet' )
        }
        
        ### Create firewall rules
        try {

            switch ($MajorVersion) {

                '10' {

                    Get-NetFirewallRule -DisplayName 'OutSystems Deployment Controller Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Deployment Controller Service' `
                                        -LocalPort 12000 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems Deployment Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Deployment Service' `
                                        -LocalPort 12001 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems Scheduler Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Scheduler Service' `
                                        -LocalPort 12002 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems Log Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Log Service' `
                                        -LocalPort 12003 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems SMS Connector Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems SMS Connector Service' `
                                        -LocalPort 12004 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null
                }

                '11' {
                    
                    Get-NetFirewallRule -DisplayName 'OutSystems Deployment Controller Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Deployment Controller Service' `
                                        -LocalPort 12000,12100 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems Deployment Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Deployment Service' `
                                        -LocalPort 12001,12101 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    Get-NetFirewallRule -DisplayName 'OutSystems Scheduler Service' | Remove-NetFirewallRule
                    New-NetFirewallRule -DisplayName 'OutSystems Scheduler Service' `
                                        -LocalPort 12002,12102 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                    if ($IncludeCacheInvalidation -eq $true) {  
                        Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service' | Remove-NetFirewallRule
                        New-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service' `
                                        -LocalPort 5672 `
                                        @FWRuleParams -ErrorAction Stop | Out-Null

                        Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (TLS)' | Remove-NetFirewallRule
                        New-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (TLS)' `
                                            -LocalPort 5671 `
                                            @FWRuleParams -ErrorAction Stop | Out-Null

                        Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (HTTP Management)' | Remove-NetFirewallRule
                        New-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (HTTP Management)' `
                                            -LocalPort 15672 `
                                            @FWRuleParams -ErrorAction Stop | Out-Null

                        Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (HTTPS Management)' | Remove-NetFirewallRule
                        New-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (HTTPS Management)' `
                                            -LocalPort 15671 `
                                            @FWRuleParams -ErrorAction Stop | Out-Null

                        Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (Clustering)' | Remove-NetFirewallRule
                        New-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service (Clustering)' `
                                            -LocalPort 4369, 25672, 35672-35682 `
                                            @FWRuleParams -ErrorAction Stop | Out-Null
                    }
                }
            }
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the firewall rules"
            WriteNonTerminalError -Message "Error creating the firewall rules"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Firewall rules for OutSystems services created successfully"

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating firewall rules for OutSystems services"

        ### Enabling firewall rules
        if ('DC' -in $OSServerRoles) {  
            Get-NetFirewallRule -DisplayName 'OutSystems Deployment Controller Service' | Enable-NetFirewallRule
        }

        if ('FE' -in $OSServerRoles) {
            Get-NetFirewallRule -DisplayName 'OutSystems Deployment Service' | Enable-NetFirewallRule
            Get-NetFirewallRule -DisplayName 'OutSystems Scheduler Service' | Enable-NetFirewallRule
        }
        elseif ( ('FE' -in $OSServerRoles) -and ($MajorVersion -eq '10') ) {
            Get-NetFirewallRule -DisplayName 'OutSystems Log Service' | Enable-NetFirewallRule
            Get-NetFirewallRule -DisplayName 'OutSystems SMS Connector Service' | Enable-NetFirewallRule
        }

        if ($IncludeCacheInvalidation -eq $true) {  
            Get-NetFirewallRule -DisplayName 'OutSystems Cache Invalidation Service' | Enable-NetFirewallRule
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Firewall rules for OutSystems services enabled successfully"

    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
