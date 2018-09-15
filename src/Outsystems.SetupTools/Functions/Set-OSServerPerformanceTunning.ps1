function Set-OSServerPerformanceTunning
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]

    <#
    .SYNOPSIS
    Configures windows and IIS with the recommended performance settings for OutSystems.

    .DESCRIPTION
    This will configure Windows and IIS with the recommended performance settings for the OutSystems platform.

    .PARAMETER IISNetCompilationPath
    Sets the IIS compilation folder.

    .PARAMETER IISHttpCompressionPath
    Sets the IIS compression folder.

    .EXAMPLE
    Set-OSServerPerformanceTunning

    .EXAMPLE
    Set-OSServerPerformanceTunning -IISNetCompilationPath d:\IISTemp\Compilation -IISHttpCompressionPath d:\IISTemp\Compression

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISNetCompilationPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISHttpCompressionPath
    )

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

        # Configure process scheduling -- http://technet.microsoft.com/library/Cc976120
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring Windows processor scheduling priority to background services"
        try
        {
            RegWrite -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type "Dword" -Value 24
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring processor scheduling priority"
            WriteNonTerminalError -Message "Error configuring processor scheduling priority"

            return
        }

        # Configure .NET
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring .NET upload size limits and execution timeout (maxRequestLength = 131072, executionTimeout = 110 seconds)"
        try
        {
            SetDotNetLimits -UploadLimit 131072 -ExecutionTimeout '00:01:50'
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring .NET settings"
            WriteNonTerminalError -Message "Error configuring .NET settings"

            return
        }

        # Configure IIS requests limits (Server Level)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS upload size limits (maxAllowedContentLength = 134217728)"
        try
        {
            SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxAllowedContentLength" -Value 134217728
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS upload size limits"
            WriteNonTerminalError -Message "Error configuring IIS upload size limits"

            return
        }

        # Configure IIS for unlimited connections. (Default Web Site) - This should not be needed cause IIS defaults to maximum.
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS for unlimited connections (MaxConnections = 4294967295)"
        try
        {
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].OverrideModeDefault" -Value "Allow"
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].allowDefinition" -Value "Everywhere"
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits" -Value @{MaxConnections = 4294967295}
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS for unlimited connections"
            WriteNonTerminalError -Message "Error configuring IIS for unlimited connections"

            return
        }

        # Configure IIS Application Pools
        $DefaultWebSiteApps = $(Get-WebApplication -Site "Default Web Site").Path

        foreach ($Config in $OSIISConfig)
        {
            # Reset array at each loop
            $InterestingApps = @()

            # Build an array with all matching Apps.
            foreach ($App in $($Config.Match))
            {
                $InterestingApps += $DefaultWebSiteApps -like $App
            }

            # if an app was found
            if ($InterestingApps.Count -gt 0)
            {

                # Check if AppPool exists. if not, create a new one.
                if (-not $(Get-ChildItem -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction SilentlyContinue))
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating IIS Application Pool $($Config.PoolName)"
                    try
                    {
                        New-Item -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction Stop | Out-Null
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating Application Pool $($Config.PoolName)"
                        WriteNonTerminalError -Message "Error creating AppPool $($Config.PoolName)"

                        return
                    }
                }

                # Configure the AppPool
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS Application Pool $($Config.PoolName)"
                $AppPoolItem = Get-Item "IIS:\AppPools\$($Config.PoolName)"

                # Commit everything on one shot
                Start-WebCommitDelay

                $AppPoolItem.managedRuntimeVersion = "v4.0"
                $AppPoolItem.managedPipelineMode = "Classic"

                $AppPoolItem.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
                $AppPoolItem.recycling.periodicRestart.requests = 0
                #$AppPoolItem.recycling.periodicRestart.requests = 0 -- specific times #TODO: specific times

                $AppPoolItem.recycling.logEventOnRecycle = "Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory"
                $AppPoolItem.processModel.idleTimeout = [TimeSpan]::FromMinutes(0)

                #TODO: Set maximum failures to 0

                $AppPoolItem.recycling.periodicRestart.privateMemory = [int]($(GetInstalledRAM) * 1MB * ($($Config.MemoryPercentage) / 100))

                $AppPoolItem | Set-Item

                # Move the InterestingApp to the AppPool
                foreach ($InterestingApp In $InterestingApps)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Moving Application $InterestingApp to Application Pool $($Config.PoolName)"
                    Set-ItemProperty -Path "IIS:\Sites\Default Web Site$InterestingApp" -Name applicationPool -Value $($Config.PoolName)
                }

                # Commit everything in one shot
                try
                {
                    Stop-WebCommitDelay
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error applying setting to Application Pool $($Config.PoolName)"
                    WriteNonTerminalError -Message "Error applying setting to Application Pool $($Config.PoolName)"

                    return
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Application Pool $($Config.PoolName) configuration done"
            }
        }

        # Configure .NET compilation folder (Server Level)
        if ($IISNetCompilationPath)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISNetCompilationPath specified on the command line"
            if (-not (Test-Path -Path $IISNetCompilationPath))
            {
                try
                {
                    New-Item -Path $IISNetCompilationPath -ItemType directory -Force -ErrorAction Stop | Out-Null
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS Net compilation folder"
                    WriteNonTerminalError -Message "Error creating the IIS Net compilation folder"

                    return
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS compilation folder to $IISNetCompilationPath"
            try
            {
                SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT" -Filter "system.web/compilation" -Name 'tempDirectory' -Value $IISNetCompilationPath
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS compilation folder"
                WriteNonTerminalError -Message "Error setting the IIS compilation folder"

                return
            }
        }

        # Configure HTTP Compression folder (Server Level)
        if ($IISHttpCompressionPath)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISHttpCompressionPath specified on the command line"
            if (-not (Test-Path -Path $IISHttpCompressionPath))
            {
                try
                {
                    New-Item -Path $IISHttpCompressionPath -ItemType directory -Force -ErrorAction Stop | Out-Null
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS HTTP compression folder"
                    WriteNonTerminalError -Message "Error creating the IIS HTTP compression folder"

                    return
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS HTTP compression folder to $IISHttpCompressionPath"
            try
            {
                SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST"  -Filter "system.webServer/httpCompression" -Name "directory" -Value $IISHttpCompressionPath
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS HTTP compression folder"
                WriteNonTerminalError -Message "Error setting the IIS HTTP compression folder"

                return
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
