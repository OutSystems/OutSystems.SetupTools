function Set-OSServerSEOFriendlyURLs
{
    <#
    .SYNOPSIS
    Configures the requirements for the SEO Friendly URLs feature of the OutSystems 11 platform

    .DESCRIPTION
    This configures on the local server the following requirements for the SEO Friendly URLs feature of the OutSystems 11 platform:
    1. Adds the OsISAPIFilterx64.dll file to the IIS ISAPI Filters
    2. Moves the IIS root application to the chosen application pool, by default the 'OutSystemsApplications' app pool.
    3. Assigns permission for the local IIS_IUSRS group to modifiy the logs folder inside the platform installation directory, 
    where logs of the ISAPI filter will be written.

    https://success.outsystems.com/documentation/11/building_apps/search_engine_optimization_in_apps/seo_for_outsystems_reactive_web_apps_vs_traditional_web_apps/seo_friendly_urls_for_traditional_web_apps/#installing-isapi-filters-and-logging

    .PARAMETER RootAppPool
    The name of the IIS application pool to where the IIS Root application will be moved. SEO URLs

    .EXAMPLE
    Set-OSServerSEOFriendlyURLs -RootAppPool CustomAppPool

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RootAppPool = 'OutSystemsApplications'
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osVersion = GetServerVersion

        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        if ($(-not $osVersion) -or $(-not $(GetServerInstallDir)))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return
        }

        if ($null -eq (Get-IISAppPool -Name $RootAppPool))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The application pool '$RootAppPool' doesn't not exist or could not be found"
            WriteNonTerminalError -Message "The application pool '$RootAppPool' does not exist or could not be found"

            return
        }

    }

    process
    {

        $PSInstall_Path = GetServerInstallDir

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring ISAPI filter DLL for SEO Friendly URLs..."

        # Configure ISAPI Filter in IIS Default Web Site
        Start-WebCommitDelay
        $OSISAPIFilterName = 'OutSystems ISAPI Filter'
        $OSISAPIFilterPath = "$($PSInstall_Path)\OsISAPIFilterx64.dll"
        $ISAPIFiltersConfig = (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Location 'Default Web Site' -Filter "system.webServer/isapiFilters" -Name '.').Collection

        if ( ($OSISAPIFilterPath -notin $ISAPIFiltersConfig.path) -and ($OSISAPIFilterName -notin $ISAPIFiltersConfig.name ) ) {

            Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                        -Location 'Default Web Site' `
                                        -Filter "system.webServer/isapiFilters" `
                                        -Name "." `
                                        -Value @{name="$($OSISAPIFilterName)";path="$($OSISAPIFilterPath)";enableCache='False';preCondition='bitness64'}
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Moving the IIS root application to app pool with OutSystems applications..."

        # Move root application to chosen application pool
        Set-ItemProperty -Path "IIS:\Sites\Default Web Site\" -Name applicationPool -Value $RootAppPool

        # Commit all IIS config changes in one shot
        try
        {
            Stop-WebCommitDelay
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error applying settings to Application Pool $RootAppPool"
            WriteNonTerminalError -Message "Error applying settings to Application Pool $RootAppPool"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Assigning Modify permissions on the Platform logs folder..."

        # Assign Modify permissions on the Platform logs folder to the IIS_IUSRS local group 
        $PSLogs_ACL = Get-ACL -Path "$($PSInstall_Path)\logs"
        $PSLogs_ACLRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", `
                                                                                        "Modify", `
                                                                                        "ContainerInherit, ObjectInherit", `
                                                                                        "None", `
                                                                                        "Allow")
        $PSLogs_ACL.SetAccessRule($PSLogs_ACLRule)
        Set-Acl -Path "$($PSInstall_Path)\logs" -AclObject $PSLogs_ACL

        #endregion

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Requirements for SEO Friendly URLs configured successfully"
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
